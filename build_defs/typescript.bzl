"""TypeScript rules.
"""
# pylint: disable=unused-argument
# pylint: disable=missing-docstring

# TODO(plf): b/33187026 Write script to replace every load(path) with the
# appropriate package path depending on whether we want the rules for blaze
# or bazel.
# load("//:common/compilation.bzl", "compile_ts")
# load("//:executables.bzl", "get_tsc", "get_node")
load("//build_defs:compilation.bzl", "compile_ts")
load("//build_defs:executables.bzl", "get_tsc", "get_node")

def _compile_action(ctx, inputs, outputs, config_file_path):
  externs_files = []
  non_externs_files = []
  for output in outputs:
    if output.basename.endswith(".externs.js"):
      externs_files.append(output)
    else:
      non_externs_files.append(output)

  # TODO(plf): For now we mock creation of files other than {name}.js.
  for externs_file in externs_files:
    ctx.file_action(output=externs_file, content="")

  ctx.action(
      inputs=inputs + [ctx.executable._node],
      outputs=non_externs_files,
      arguments=["-p", config_file_path],
      executable=ctx.executable._tsc,
      env={"PATH": ctx.executable._node.dirname},)


def _devmode_compile_action(ctx, inputs, outputs, config_file_path):
  _compile_action(ctx, inputs, outputs, config_file_path)


def _files_to_json_array(tsconfig_path, files):
  """Returns a string with files in JSON array format.

  The location of tsconfig.json is interpreted as the root of the project
  when it is passed to the TS compiler with the `-p` option:
    https://www.typescriptlang.org/docs/handbook/tsconfig-json.html.

  Our tsconfig.json is in bazel-foo/bazel-out/local-fastbuild/bin/{package_path}
  because it's generated in the execution phase. However, our source files are in
  bazel-foo/ and therefore we need to strip some parent directories for each
  f.path.

  Args:
    tsconfig_path: path to tsconfig.json.
    files: files to compile.
  Returns:
    file entry of JSON tsconfig.
  """
  num_levels_up = len(tsconfig_path.split("/")) - 1
  parent_dir = "../" * num_levels_up
  return ("[\n" + ",\n".join(
      ["        \"%s%s\"" % (parent_dir, f.path) for f in files]) + "]")


def _tsc_wrapped_tsconfig(ctx,
                          files,
                          srcs,
                          es5_manifest=None,
                          tsickle_externs=None,
                          allowed_deps=set(),
                          ngc_out=[]):
  template = """
{{
  "compilerOptions": {{
    "outDir": "."
  }},
  {files_array}
}}
  """
  tsconfig_json = ctx.new_file("tsconfig.json")
  files_array = ("\"files\": " + _files_to_json_array(tsconfig_json.path, files) + "\n")
  ctx.file_action(
      output=tsconfig_json,
      content=template.format(
          bin_dir_path=ctx.configuration.bin_dir.path, files_array=files_array))
  return tsconfig_json

# ************ #
# ts_library   #
# ************ #


def _ts_library_impl(ctx):
  """Implementation of ts_library.

  Args:
    ctx: the context.
  Returns:
    the struct returned by the call to compile_ts.
  """

  return compile_ts(ctx, is_library=True, compile_action=_compile_action,
                    devmode_compile_action=_devmode_compile_action,
                    tsc_wrapped_tsconfig=_tsc_wrapped_tsconfig)

ts_library = rule(
    _ts_library_impl,
    attrs={
        "srcs":
            attr.label_list(
                allow_files=FileType([
                    ".ts",
                    ".tsx",
                ]),
                mandatory=True,),
        "deps":
            attr.label_list(),
        # TODO(evanm): make this the default and remove the option.
        "runtime":
            attr.string(default="browser"),
        "_additional_d_ts":
            attr.label_list(),
        "_tsc":
            attr.label(
                default=get_tsc(),
                single_file=False,
                allow_files=True,
                executable=True,
                cfg="host",),
        "_node":
            attr.label(
                default=get_node(),
                single_file=True,
                allow_files=True,
                executable=True,
                cfg="host",),
    },
    fragments=["js"],
    outputs={"_js_typings": "_%{name}_js_typings.d.ts"},)
