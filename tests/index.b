import ..app {*}

describe('main test', @() {
  it('should work', @() {
    var razor = Razor(true)

    razor.set_title('Blade Browser')
    razor.set_size(480, 320, HINT_NONE)

    razor.bind('save', @(req) {
      # die Exception('something went wrong!')
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
})