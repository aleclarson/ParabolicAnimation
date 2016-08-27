var Animation, Easing, LazyVar, Type, gauss, type;

Animation = require("Animated").Animation;

LazyVar = require("LazyVar");

Easing = require("easing");

gauss = require("gaussian-elimination");

Type = require("Type");

type = Type("ParabolicAnimation");

type.inherits(Animation);

type.defineOptions({
  endValue: Number.isRequired,
  velocity: Number.isRequired,
  duration: Number.isRequired
});

type.defineFrozenValues(function(options) {
  return {
    endValue: options.endValue,
    startVelocity: options.velocity,
    duration: options.duration,
    _vertex: LazyVar((function(_this) {
      return function() {
        return _this._computeVertex();
      };
    })(this)),
    _velocity: LazyVar((function(_this) {
      return function() {
        return _this._computeVelocity(_this.time / 1000);
      };
    })(this))
  };
});

type.defineValues({
  progress: 0,
  time: null,
  value: null,
  _coeff: function() {
    var dt;
    dt = this.duration / 1000;
    return gauss([[0, 0, 1], [Math.pow(dt, 2), dt, 1], [0, 1, 0]], [this.startValue, this.endValue, this.startVelocity]);
  }
});

type.defineGetters({
  vertex: function() {
    return this._vertex.get();
  },
  velocity: function() {
    return this._velocity.get();
  }
});

type.defineMethods({
  valueAtTime: function(dt) {
    return this._coeff[0] * Math.pow(dt / 1000, 2) + this._coeff[1] * (dt / 1000) + this._coeff[2];
  },
  _computeVelocity: function(dt) {
    return 2 * this._coeff[0] * (dt / 1000) + this._coeff[1];
  },
  _computeVertex: function() {}
});

type.overrideMethods({
  __didStart: function(config) {
    this.time = this.startTime = Date.now();
    this.value = this.startValue = config.startValue;
    return this._requestAnimationFrame();
  },
  __computeValue: function() {
    this._velocity.reset();
    this.time = Math.min(this.duration, Date.now() - this.startTime);
    this.progress = this.time / this.duration;
    return this.value = this.valueAtTime(this.time);
  },
  __didUpdate: function(value) {
    if (this.time === this.duration) {
      return this.finish();
    }
  },
  __captureFrame: function() {
    return {
      value: this.value,
      velocity: this.velocity,
      time: this.time,
      progress: this.progress
    };
  }
});

module.exports = type.build();

//# sourceMappingURL=map/ParabolicAnimation.map
