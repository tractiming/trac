 function pseudo_popup(content) {
    /* There are lots of ways to create the content, but for simplicity
    * this will just assume an HTML string */
 
    var popup = document.createElement("div");
 
    popup.innerHTML = content;
 
    /* Change this to suit your style */
    popup.style.background = "1000px white";
    popup.style.border = "10px solid #FFFFFF";
 
    /* To make it "pop out" a bit more, it can have a shadow. */
    if( navigator.userAgent.match(/msie/i) ) {
      /* Internet Explorer uses linear gradients for this, so give it
      * three such shadows to look more "3D"
      */
      function shadow_filter(spec) {
        return "progid:DXImageTransform.Microsoft.Shadow(" + spec + ")";
      }
      popup.style.filter = [
        shadow_filter("color=black, strength=5"),
        shadow_filter("color=black, strength=2, direction=135"),
        shadow_filter("color=black, strength=2, direction=315")
      ].join(" ");
    } else {
      /* Most other browsers support CSS3 shadows */
      popup.style.MozBoxShadow =
        popup.style.webkitBoxShadow =
          popup.style.BoxShadow = "-4px 4px 11px black";
    }
 
    var viewport_width = window.innerWidth;
    var viewport_height = window.innerHeight;
 
    /* It's important to allow the box to be dismissed. In this case,
    * it's a gently shaded clickable underlay.
    */
    function add_underlay() {
      var underlay = document.createElement("div");
 
      /* Set it to be "full screen" */
      underlay.style.position = "fixed";
      underlay.style.top = "0px";
      underlay.style.left = "0px";
      underlay.style.width = viewport_width + "px";
      underlay.style.height = viewport_height + "px";
 
      /* Set its background as compatibly as possible */
      underlay.style.background = "#7f7f7f";
      if( navigator.userAgent.match(/msie/i) ) {
        /* Internet Explorer requires a filter */
        underlay.style.background = "#7f7f7f";
        underlay.style.filter =
          "progid:DXImageTransform.Microsoft.Alpha(opacity=50)";
      } else {
        /* Pretty much everything else can do RGBA */
        underlay.style.background = "rgba(127, 127, 127, 0.5)";
      }
 
      /* Make clicking it close both */
      underlay.onclick = function() {
        underlay.parentNode.removeChild(underlay);
        popup.parentNode.removeChild(popup);
      };
      document.body.appendChild(underlay);
    }
 
    add_underlay();
   
    /* Get the viewport centre */
    var x = viewport_width / 2;
    var y = viewport_height / 2;
 
    /* Lock it relative to the viewport */
    popup.style.position = "fixed";
 
    document.body.appendChild(popup);
 
    /* Find its size and adjust to centre */
    x -= popup.clientWidth / 2;
    y -= popup.clientHeight / 2;
 
    popup.style.top = y + "px";
    popup.style.left = x + "px";
 
    return false;
  }