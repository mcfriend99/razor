# razor

[Webview](https://github.com/webview/webview) bindings for Blade for build modern cross-platform GUIs.

![screenshot](https://raw.githubusercontent.com/mcfriend99/razor/refs/heads/main/images/razor-blade.png)

### Installation

You can install the package via Nyssa:

```
nyssa install razor
```

Or like any Blade package, you can download it and extract it into `<PROJECT_ROOT>/.blade/libs/` directory.

### Support

This library comes with pre-built webview binaries for the following platforms:

- `Linux`: aarch64, arm, i386 (x64), and amd64 (x86_64)
- `MacOS`: aarch64 (M1, M2...), and amd64 (x86_64 - Intel)
- `Windows`: x86, x64 (x86_64)

### Usage

1. Import the Razor module
   
   ```blade
   import razor
   ```

2. Create a new Razor instance
   
   ```blade
   var app = Razor()
   ```

   You can also set the window size and/or whether to enable debug or not.

   ```
   var app = Razor(640, 480, true)
   ```

   The above example sets the width to 640, height to 480, and enables debugging.
   You can set any of them to `nil` to enable the default.

   By default, the width is `480` and height is `320` while debug is disabled by default.

3. Set url, title, etc.
   
   ```blade
   app.set_title('Blade Browser').
        set_size(480, 320, HINT_NONE).
        navigate('https://bladelang.org')
   ```

   Functions are chaninable except functions expected to return a value (getters) such as `get_window()`. 
   
   See below for a list of all functions.

4. Run the webview
   
   ```blade
   app.run()
   ```

### Calling Blade functions from JavaScript

To call a Blade function from JS, you need to first bind the function. The example below binds the Blade 
function `reply` allowing the JS code to call it.

```blade
app.bind('reply', @(args) {
  echo args
  return args
})
```

And then in HTML/JS,

```html
<center>Hello World</center>
<script>
  async function test() {
    document.querySelector("center").innerHTML = (await reply("Hello Again"))
  }
  test()
</script>
```

> **NOTE:** Blade functions are asynchronous in JS.

### Running JS code from Blade

Use the `eval()` function to run JS code from Blade. For example,

```blade
app.eval("console.log('It works!')")
```


## Api Documentation

### `class Razor`

class Razor implements and exposes the WebView interface.

#### @constructor(width, height, debug)

Creates a new Razor instance.

- **@param** *number?* width - The width of the window (optional) - Default: 480
- **@param** *number?* height - The height of the window (optional) - Default: 320
- **@param** *bool* debug - Enable developer tools if supported by the backend.

#### `destroy()`

Destroys a webview instance and closes the window.

- **@returns** *self*

#### `run()`

Runs the main loop until it's terminated.

- **@returns** *self*

#### `terminate()`

Stops the main loop. It is safe to call this function from another other
background thread.

- **@returns**

#### `get_window()`

Returns the native handle of the window associated with the webview instance.
The handle can be a `GtkWindow` pointer (GTK), `NSWindow` pointer (Cocoa)
or `HWND` (Win32).

- **@returns** *ptr* - The handle of the native window.

#### `set_title(title)`

Updates the title of the native window.

- **@param** *string* title - The new title.
- **@returns** *self*

#### `set_size(width, height, hints)`

Updates the size of the native window.

Remarks:
- Using `HINT_MAX` for setting the maximum window size is not
  supported with GTK 4 because X11-specific functions such as
  gtk_window_set_geometry_hints were removed. This option has 
  no effect when using GTK 4.

- **@param** *number* width - New width.
- **@param** *number?* height - New height (optional) - Default: 320.
- **@param** *number?* hints - Size hints (Optional - One of more of HINT_
   constants) - Default: `HINT_NONE`.
- **@returns** *self*

#### `navigate(url)`

Navigates razor to the given URL. URL may be a properly encoded data URI.

Example:

```blade
razor.navigate('https://github.com/webview/webview');
razor.navigate('data:text/html,%3Ch1%3EHello%3C%2Fh1%3E');
razor.navigate('data:text/html;base64,PGgxPkhlbGxvPC9oMT4=');
```

- **@param** *string* url - URL.
- **@returns** *self*

#### `set_html(html)`

Load HTML content into the razor.

Example:

```blade
razor.set_html(w, "<h1>Hello</h1>");
```

- **@param** *string* html - HTML content.
- **@returns** 

#### `load_file(path)`

Loads a file into razor.

- **@params** *string* path - File path.
- **@returns** *self*

#### `init(js)`

Injects JavaScript code to be executed immediately upon loading a page.
The code will be executed before `window.onload`.

- **@param** *string* js - JS content.
- **@returns** *self*

#### `eval(js)`

Evaluates arbitrary JavaScript code.

Use bindings if you need to communicate the result of the evaluation.

- **@param** *string* js - JS content.
- **@returns** *self*

#### `bind(name, callback)`

Binds a function pointer to a new global JavaScript function.

Internally, JS glue code is injected to create the JS function 
by the given name. The callback function is passed the request 
from JS as a JSON object (which means it can be one of nil, 
boolean, string, list or dictionary).

- **@param** *string* name - Name of the JS function.
- **@param** *function* callback - Callback function.
- **@returns** *self*

#### `unbind(name)`

Removes a binding created with `bind()`.

- **@param** *string* name - Name of the binding.
- **@returns** *self*


## Contribution

All suggestions, pull requests, issues, discussions and other contributions are welcome and appreciated.  
[Contributors](https://github.com/mcfriend99/razor/graphs/contributors)

