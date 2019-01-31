// Generated by LiveScript 1.3.1
var slice$ = [].slice;
(function(){
  var ldLoader;
  ldLoader = function(opt){
    var this$ = this;
    opt == null && (opt = {});
    this.opt = import$({
      activeClass: 'running',
      baseZ: 10000,
      autoZ: true,
      className: ''
    }, opt);
    ['root', 'container'].map(function(n){
      if (opt[n]) {
        return this$[n] = typeof opt[n] === 'string'
          ? document.querySelector(opt[n])
          : opt[n];
      }
    });
    if (!this.container) {
      this.container = this.root
        ? this.root.parentNode
        : document.body;
    }
    if (!this.root) {
      this.root = document.createElement("div");
      this.container.appendChild(this.root);
    }
    this.root.classList.add.apply(this.root.classList, (this.opt.className || '').split(' ').filter(function(it){
      return it;
    }));
    this.root.classList.remove(opt.activeClass);
    this.running = false;
    this.count = 0;
    return this;
  };
  ldLoader.prototype = import$(Object.create(Object.prototype), {
    on: function(delay){
      delay == null && (delay = 0);
      return this.toggle(true, delay);
    },
    off: function(delay){
      delay == null && (delay = 0);
      return this.toggle(false, delay);
    },
    render: function(){
      var runid, _, ret, this$ = this;
      if (!(this.running && this.opt.ctrl && this.opt.ctrl.step)) {
        return this.runid = -1;
      }
      this.runid = runid = Math.random();
      _ = function(t){
        if (this$.runid === runid) {
          requestAnimationFrame(function(it){
            return _(it);
          });
        }
        partialize$.apply(this$, [requestAnimationFrame, [void 8], [0]]);
        return this$.opt.ctrl.step.call(this$.root, t);
      };
      return ret = requestAnimationFrame(function(it){
        return _(it);
      });
    },
    toggle: function(v, delay){
      var d, running, z, ref$, idx, this$ = this;
      delay == null && (delay = 0);
      if (delay) {
        return setTimeout(function(){
          return this$.toggle(v);
        }, delay);
      }
      d = !(v != null)
        ? this.root.classList.contains(this.opt.activeClass) ? -1 : 1
        : v
          ? 1
          : -1;
      this.count += d;
      if (this.count >= 2 || (this.count === 1 && d < 0)) {
        return;
      }
      this.root.classList[!(v != null)
        ? 'toggle'
        : v ? 'add' : 'remove'](this.opt.activeClass);
      this.running = running = this.root.classList.contains(this.opt.activeClass);
      if (!this.opt.autoZ) {
        return;
      }
      if (running) {
        this.root.style.zIndex = this.z = z = ((ref$ = ldLoader.zstack)[ref$.length - 1] || 0) + this.opt.baseZ;
        ldLoader.zstack.push(z);
      } else {
        if ((idx = ldLoader.zstack.indexOf(this.z)) < 0) {
          return;
        }
        this.root.style.zIndex = "";
        ldLoader.zstack.splice(idx, 1);
      }
      if (this.opt.ctrl) {
        return this.render();
      }
    }
  });
  import$(ldLoader, {
    zstack: []
  });
  return window.ldLoader = ldLoader;
})();
function import$(obj, src){
  var own = {}.hasOwnProperty;
  for (var key in src) if (own.call(src, key)) obj[key] = src[key];
  return obj;
}
function partialize$(f, args, where){
  var context = this;
  return function(){
    var params = slice$.call(arguments), i,
        len = params.length, wlen = where.length,
        ta = args ? args.concat() : [], tw = where ? where.concat() : [];
    for(i = 0; i < len; ++i) { ta[tw[0]] = params[i]; tw.shift(); }
    return len < wlen && len ?
      partialize$.apply(context, [f, ta, tw]) : f.apply(context, ta);
  };
}