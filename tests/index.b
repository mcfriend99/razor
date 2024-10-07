import ..app {*}

describe('main test', @{
  it('should throw with wrong constructor parameter', @{
    expect(@{
      Razor(true)
    }).to_throw()
  })

  var razor = Razor()

  it('should set title correctly', @{
    expect(@{
      razor.set_title('Blade Browser')
    }).not().to_throw()
  })

  it('should set size correctly', @{
    expect(@{
      razor.set_size(480, 320, HINT_NONE)
    }).not().to_throw()
  })

  it('should bind function correctly', @{
    expect(@{
      razor.bind('save', @(args) {
        return args
      })
      razor.bind('dummy_save', @(args) {
        return args
      })
    }).not().to_throw()
  })

  it('should set confirm callback while binding a function', @{
    expect(@{
      razor.bind('save2', @{
        return args
      })
    }).to_throw()
  })

  it('should work with html string', @{
    expect(@{
      razor.set_html(
        '<center> Hello World </center>
        <script>
          async function test() {
            document.querySelector("center").innerHTML = (await save("hello"))
          }
          test()
        </script>
        '
      )
    }).not().to_throw()
  })

  it('should unbind without throwing', @{
    expect(@{
      razor.unbind('dummy_save')
    }).not().to_throw()
  })

  it('should run without throwing', @{
    expect(@{
      razor.run()
    }).not().to_throw()
  })

  it('should work with html page', @{
    razor = Razor()

    expect(@{
      razor.navigate('https://bladelang.org')
    }).not().to_throw()

    expect(@{
      razor.run()
    }).not().to_throw()
  })

  it('should work with html file', @{
    razor = Razor()

    expect(@{
      razor.load_file('./tests/testpage.html')
    }).not().to_throw()

    expect(@{
      razor.run()
    }).not().to_throw()
  })

  it('should destroy without throwing', @{
    razor = Razor()

    expect(@{
      razor.run()
    }).not().to_throw()
    
    expect(@{
      razor.destroy()
    }).not().to_throw()
  })

  it('should run init script', @{
    razor = Razor()

    var logs = []

    expect(@{
      razor.bind('console_log', @(args) {
        var log = ' '.join(args)
        logs.append(log)
        echo log
        return nil
      })
    }).not().to_throw()

    expect(@{
      razor.init(
        "console.log = (...args) => {
          console_log(...args)
        }"
      )
    }).not().to_throw()

    expect(@{
      razor.set_html("
        <h1>Title</h1>
        <script>
          console.log('Hello,', 'World!')
        </script>
      ")
    }).not().to_throw()

    expect(@{
      razor.run()
    }).not().to_throw()

    expect(logs.length()).to_be(1)
    expect(logs).to_be(['Hello, World!'])
    
    expect(@{
      razor.destroy()
    }).not().to_throw()
  })

  it('should eval JS correctly', @{
    razor = Razor()

    expect(@{
      razor.eval("document.write('Hello World Eval')")
    }).not().to_throw()

    expect(@{
      razor.run()
    }).not().to_throw()
    
    expect(@{
      razor.destroy()
    }).not().to_throw()
  })
})