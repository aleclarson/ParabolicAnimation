
createMockRaf = require "mock-raf"
Easing = require "easing"

ParabolicAnimation = require ".."

describe "ParabolicAnimation", ->

  it "animates", (done) ->

    mockRaf = createMockRaf()
    Date.now = mockRaf.now
    global.requestAnimationFrame = mockRaf.raf

    anim = ParabolicAnimation
      easing: Easing.bezier 0, 0, 1, 1
      startValue: 100
      endValue: 0
      velocity: 50
      duration: 3200
      captureFrames: yes

    anim.start
      onEnd: (finished) ->
        expect finished
          .toBe yes
        done()

    mockRaf.step
      count: 201
      time: 16

    repl.sync {anim}
