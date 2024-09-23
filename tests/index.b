import ..app {*}

describe('main test', @() {
  it('should work with html string', @() {
    var razor = Razor(true)

    razor.set_title('Blade Browser')
    razor.set_size(480, 320, HINT_NONE)

    razor.bind('save', @(req) {
      return req
    })

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
    
    razor.run()

    expect(@(){
      razor.destroy()
    }).not().to_throw()
  })

  it('should work with html page', @() {
    var razor = Razor(true)

    razor.set_title('Blade Browser')
    razor.set_size(480, 320, HINT_NONE)

    razor.bind('save', @(req) {
      return req
    })

    razor.navigate('https://google.com')
    
    razor.run()

    expect(@(){
      razor.destroy()
    }).not().to_throw()
  })

  it('should work with html file', @() {
    var razor = Razor(true)

    razor.set_title('Blade Browser')
    razor.set_size(480, 320, HINT_NONE)

    razor.bind('save', @(req) {
      return req
    })

    razor.load_file('./tests/testpage.html')
    
    razor.run()

    expect(@(){
      razor.destroy()
    }).not().to_throw()
  })
})