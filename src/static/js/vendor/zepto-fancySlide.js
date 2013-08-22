(function ($) {
  $.fn.fancySlide = function (duration) {

    var position = this.css("position");

    this.show();

    this.css({
      position: "absolute",
      visibility: "hidden"
    });

    var height = this.height();

    this.css({
      position: position,
      visibility: "visible",
      overflow: "hidden",
      height: 0
    });

    this.animate({
      height: height
    }, duration);
  };
})(Zepto);
