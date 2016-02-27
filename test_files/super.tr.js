class SuperTestBaseNoArg {
    constructor() {
    }
}
class SuperTestBaseOneArg {
    constructor(x) {
        this.x = x;
    }
    static _sickle_typeAnnotationsHelper() {
        /** @type { number} */
        SuperTestBaseOneArg.prototype.x;
    }
}
// A ctor with a parameter property.
class SuperTestDerivedParamProps extends SuperTestBaseOneArg {
    constructor(y) {
        super(3);
        this.y = y;
    }
    static _sickle_typeAnnotationsHelper() {
        /** @type { string} */
        SuperTestDerivedParamProps.prototype.y;
    }
}
// A ctor with an initialized property.
class SuperTestDerivedInitializedProps extends SuperTestBaseOneArg {
    constructor() {
        super(3);
        this.y = 'foo';
    }
    static _sickle_typeAnnotationsHelper() {
        /** @type { string} */
        SuperTestDerivedInitializedProps.prototype.y;
    }
}
// A ctor with a super() but none of the above two details.
class SuperTestDerivedOrdinary extends SuperTestBaseOneArg {
    constructor() {
        super(3);
    }
}
// A class without a ctor, extending a one-arg ctor parent.
class SuperTestDerivedNoCTorNoArg extends SuperTestBaseNoArg {
}
// A class without a ctor, extending a no-arg ctor parent.
class SuperTestDerivedNoCTorOneArg extends SuperTestBaseOneArg {
}
// A class implementing an interface.
class SuperTestDerivedInterface {
    static _sickle_typeAnnotationsHelper() {
        /** @type { number} */
        SuperTestDerivedInterface.prototype.foo;
    }
}
class SuperTestStaticProp extends SuperTestBaseOneArg {
}
SuperTestStaticProp.foo = 3;
