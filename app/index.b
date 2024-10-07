import clib
import os
import json
import reflect

import .hints {*}


/**
 * class Razor implements and exposes the WebView interface.
 * 
 * @class
 */
class Razor {
  var _webview
  var _lib
  var _library_file

  /**
   * Creates a new Razor instance.
   * 
   * @param {number?} width - The width of the window (optional) - Default: 480
   * @param {number?} height - The height of the window (optional) - Default: 320
   * @param {bool} debug - Enable developer tools if supported by the backend.
   * @constructor
   */
  Razor(width, height, debug) {

    if width == nil width = 480

    if (width != nil and !is_number(width)) or
        (height != nil and !is_number(height)) {
      raise Exception('invalid window size')
    }

    if debug == nil {
      debug = false
    } else if !is_bool(debug) {
      raise Exception('debug must be boolean')
    }

    self._load()
    self._webview = self._create(debug ? 1 : 0, nil)
    self.set_size(width, height)
  }

  /**
   * Destroys a webview instance and closes the window.
   * 
   * @returns self
   */
  destroy() {
    self._destroy(self._webview)
    return self
  }

  /**
   * Runs the main loop until it's terminated.
   * 
   * @returns self
   */
  run() {
    self._run(self._webview)
    return self
  }

  /**
   * Stops the main loop. It is safe to call this function from another other
   * background thread.
   * 
   * @returns self
   */
  terminate() {
    self._terminate(self._webview)
    return self
  }

  /**
   * Returns the native handle of the window associated with the webview instance.
   * The handle can be a `GtkWindow` pointer (GTK), `NSWindow` pointer (Cocoa)
   * or `HWND` (Win32).
   * 
   * @returns {ptr} - The handle of the native window.
   */
  get_window() {
    return self._get_window(self._webview)
  }

  /**
   * Updates the title of the native window.
   * 
   * @param {string} title - The new title.
   * @returns self
   */
  set_title(title) {
    if !is_string(title) {
      raise Exception('string expected')
    }

    self._set_title(self._webview, title)
    return self
  }

  /**
   * Updates the size of the native window.
   *
   * Remarks:
   * - Using `HINT_MAX` for setting the maximum window size is not
   *   supported with GTK 4 because X11-specific functions such as
   *   gtk_window_set_geometry_hints were removed. This option has 
   *   no effect when using GTK 4.
   *
   * @param {number} width - New width.
   * @param {number?} height - New height (optional) - Default: 320.
   * @param {number?} hints - Size hints (Optional - One of more of HINT_* 
   *    constants) - Default: `HINT_NONE`.
   * @returns self
   */
  set_size(width, height, hints) {
    if !height height = 320
    if !hints hints = HINT_NONE

    if !is_number(width) or !is_number(height) {
      raise Exception('number expected for width and/or height')
    } else if !is_number(hints) {
      raise Exception('HINT_* expected for hints')
    }

    self._set_size(self._webview, width, height, hints)
    return self
  }

  /**
   * Navigates razor to the given URL. URL may be a properly encoded data URI.
   *
   * Example:
   * 
   * ```blade
   * razor.navigate('https://github.com/webview/webview');
   * razor.navigate('data:text/html,%3Ch1%3EHello%3C%2Fh1%3E');
   * razor.navigate('data:text/html;base64,PGgxPkhlbGxvPC9oMT4=');
   * ```
   *
   * @param {string} url - URL.
   * @returns self
   */
  navigate(url) {
    if !is_string(url) {
      raise Exception('string expected')
    }
    
    self._navigate(self._webview, url)
    return self
  }

  /**
   * Load HTML content into the razor.
   *
   * Example:
   * 
   * ```blade
   * razor.set_html(w, "<h1>Hello</h1>");
   * ```
   *
   * @param {string} html - HTML content.
   * @returns self
   */
  set_html(html) {
    if !is_string(html) {
      raise Exception('string expected')
    }
    
    self._set_html(self._webview, html)
    return self
  }

  /**
   * Loads a file into razor.
   * 
   * @params {string} path - File path.
   * @returns self
   */
  load_file(path) {
    if !is_string(path) {
      raise Exception('string expected')
    }
    
    var fh = file(path)
    if(fh.exists()) {
      var abs_path = fh.abs_path()
      self.navigate('file://${abs_path}')
    }

    return self
  }

  /**
   * Injects JavaScript code to be executed immediately upon loading a page.
   * The code will be executed before `window.onload`.
   *
   * @param {string} js - JS content.
   * @returns self
   */
  init(js) {
    if !is_string(js) {
      raise Exception('string expected')
    }
    
    self._init(self._webview, js)
    return self
  }

  /**
   * Evaluates arbitrary JavaScript code.
   *
   * Use bindings if you need to communicate the result of the evaluation.
   *
   * @param {string} js - JS content.
   * @returns self
   */
  eval(js) {
    if !is_string(js) {
      raise Exception('string expected')
    }
    
    self._eval(self._webview, js)
    return self
  }

  /**
   * Binds a function pointer to a new global JavaScript function.
   *
   * Internally, JS glue code is injected to create the JS function 
   * by the given name. The callback function is passed the request 
   * from JS as a JSON object (which means it can be one of nil, 
   * boolean, string, list or dictionary).
   *
   * @param {string} name - Name of the JS function.
   * @param {function} callback - Callback function.
   * @returns self
   */
  bind(name, callback) {
    if !is_string(name) {
      raise Exception('string expected for name')
    } else if !is_function(callback) {
      raise Exception('function expected for callback')
    } else if reflect.get_function_metadata(callback).arity == 0 {
      raise Exception('callback function must accept at least 1 argument')
    }
    
    self._bind(
      self._webview, 
      name, 
      clib.create_callback(@(seq, req, args) {
        catch {
          var res =  callback(json.decode(req))
          if res {
            if !is_dict(res) and !is_list(res) {
              res = [res]
            }

            self._do_return(seq, 0, res)
          }
        } as e 
        
        if e {
          echo '${typeof(e)}: ${e.message}\n${e.stacktrace}'
          self._do_return(seq, 1, e.message)
        }
      }, clib.int, clib.char_ptr, clib.char_ptr, clib.ptr), 
      nil
    )
    return self
  }

  /**
   * Removes a binding created with `bind()`.
   *
   * @param string name - Name of the binding.
   * @returns self
   */
  unbind(name) {
    if !is_string(name) {
      raise Exception('string expected')
    }
    
    self._unbind(self._webview, name)
    return self
  }

  _do_return(seq, status, result) {
    self._return(self._webview, seq, status, json.encode(result))
    return self
  }

  _load() {
    if self._lib {
      return self._lib
    }

    self._lib = clib.load(self._get_library_file())

    # ADD BINDINGS

    # create(debug, ancestor)
    self._create = self._lib.define('webview_create', clib.ptr, clib.int, clib.ptr)

    # destroy(webview)
    self._destroy = self._lib.define('webview_destroy', clib.void, clib.ptr)

    # run(webview)
    self._run = self._lib.define('webview_run', clib.void, clib.ptr)

    # terminate(webview)
    self._terminate = self._lib.define('webview_terminate', clib.void, clib.ptr)

    # get_window(webview)
    self._get_window = self._lib.define('webview_get_window', clib.ptr, clib.ptr)

    # set_title(webview, title)
    self._set_title = self._lib.define('webview_set_title', clib.void, clib.ptr, clib.char_ptr)

    # set_size(webview, width, height, hints)
    self._set_size = self._lib.define('webview_set_size', clib.void, clib.ptr, clib.int, clib.int, clib.int)

    # navigate(webview, url)
    self._navigate = self._lib.define('webview_navigate', clib.void, clib.ptr, clib.char_ptr)

    # set_html(webview, html)
    self._set_html = self._lib.define('webview_set_html', clib.void, clib.ptr, clib.char_ptr)

    # eval(webview, js)
    self._eval = self._lib.define('webview_eval', clib.void, clib.ptr, clib.char_ptr)

    # init(webview, js)
    self._init = self._lib.define('webview_init', clib.void, clib.ptr, clib.char_ptr)

    # bind(webview, name, callback, arguments)
    self._bind = self._lib.define('webview_bind', clib.void, clib.ptr, clib.char_ptr, clib.function, clib.ptr)

    # unbind(webview, name)
    self._unbind = self._lib.define('webview_unbind', clib.void, clib.ptr, clib.char_ptr)

    # wreturn(webview, seq, status, result)
    self._return = self._lib.define('webview_return', clib.void, clib.ptr, clib.char_ptr, clib.int, clib.char_ptr)
  }

  _get_library_file() {
    if self._library_file {
      return self._library_file
    }

    var base = os.dir_name(__file__)

    var arch = os.info().machine
    if os.platform == 'osx' and arch == 'arm64' {
      arch = 'aarch64'
    }

    using os.platform {
      when 'linux' self._library_file = os.join_paths(base, '../bin/${arch}/linux/webview.so') 
      when 'osx' self._library_file = os.join_paths(base, '../bin/${arch}/osx/webview.dylib') 
      when 'windows' self._library_file = os.join_paths(base, '../bin/${arch}/windows/webview.dll') 
      default raise Exception('unsupported OS')
    }
    
    return self._library_file
  }
}
