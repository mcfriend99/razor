/**
 * Missing dependency.
 */
var RAZOR_MISSING_DEPENDENCY = -5

/**
 * Operation canceled.
 */
var RAZOR_CANCELED = -4

/**
 * Invalid state detected.
 */
var RAZOR_INVALID_STATE = -3

/**
 * One or more invalid arguments have been specified 
 * e.g. in a function call.
 */
var RAZOR_INVALID_ARGUMENT = -2

/**
 * An unspecified error occurred. A more specific error 
 * code may be needed.
 */
var RAZOR_UNSPECIFIED = -1

/**
 * OK/Success. Functions that return error codes will 
 * typically return this to signify successful operations.
 */
var RAZOR_OK = 0

/**
 * Signifies that something already exists.
 */
var RAZOR_DUPLICATE = 1

/**
 * Signifies that something does not exist.
 */
var RAZOR_NOT_FOUND = 2
