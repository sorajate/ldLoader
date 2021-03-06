(->
  ldLoader = (opt={}) ->
    @opt = {active-class: \running, base-z: 4000, auto-z: false, class-name: '', atomic: true} <<< opt
    <[root container]>.map (n) ~> if opt[n] =>
      @[n] = (if Array.isArray(opt[n]) => opt[n] else [opt[n]]).map ->
        ret = if typeof(it) == \string => document.querySelector(it) else it
        if !ret => console.warn "[ldLoader] warning: no node found for #it"
        ret
    if !@container => @container = if @root => @root.map(-> it.parentNode) else [document.body]
    if !@root => @root = @container.map ->
        node = document.createElement("div")
        it.appendChild node
        return node
    @root.map ~>
      it.classList.add.apply it.classList, (@opt.class-name or '').split(' ').filter(->it)
      it.classList.remove opt.active-class
      if opt.inactive-class => it.classList.add opt.inactive-class
    @ <<< running: false, count: 0
    @

  ldLoader.prototype = Object.create(Object.prototype) <<< do
    is-on: -> return @running
    on: (delay=0) -> @toggle true, delay
    off: (delay=0, force = false) -> @toggle false, delay, force
    # if v defined, force state to v.
    cancel: (v) -> clearTimeout @handle; if v? => @toggle v
    flash: (dur=1000, delay=0) -> @toggle(true, delay).then ~> @toggle false, dur + delay
    render: ->
      if !(@running and @opt.ctrl and @opt.ctrl.step) => return @render.runid = -1
      @render.runid = runid = Math.random!
      @render.start = 0
      if @opt.ctrl.init => @root.map ~> @opt.ctrl.init.call it
      _ = (t) ~>
        if !@render.start => @render.start = t
        @root.map ~> @opt.ctrl.step.call it, (t - @render.start)
        if @render.runid == runid => requestAnimationFrame -> _ it
        else if @opt.ctrl.done => @root.map ~> @opt.ctrl.done.call it, (t - @render.start)
      ret = requestAnimationFrame -> _ it
    toggle: (v, delay=0, force = false) ->
      d = (if !(v?) => (if @root.0.classList.contains @opt.active-class => -1 else 1) else if v => 1 else -1)
      if @handle => @cancel!
      if delay => return new Promise (res, rej) ~>
        # new approach - treat delay directly as a simple delay before action.
        @handle = setTimeout (~> @toggle(v)then ~> res!), delay
        # old approach
        # if is on: resolve after on
        #if d > 0 => @toggle(v)then ~> setTimeout (~> res!), delay
        # if is off: off after resolve
        #else => setTimeout (~> @toggle(v)then ~> res!), delay
      new Promise (res, rej) ~>
        @count = (@count + d >? 0)
        if !force and !@opt.atomic and ( @count >= 2 or (@count == 1 and d < 0)) => return res!
        @root.map ~>
          it.classList.toggle @opt.active-class, (d > 0)
          if @opt.inactive-class => it.classList.toggle @opt.inactive-class, (d < 0)
        @running = running = @root.0.classList.contains(@opt.active-class)
        if @opt.ctrl => @render!
        if !@opt.auto-z => return res!
        if running =>
          if ldLoader.zmgr => @z = ldLoader.zmgr.add @opt.base-z
          else
            @z = (ldLoader.zstack[* - 1] or @opt.base-z) + 1
            ldLoader.zstack.push z
          @root.map ~> it.style.zIndex = @z
        else
          if ldLoader.zmgr => ldLoader.zmgr.remove @z
          else
            if (idx = ldLoader.zstack.indexOf(@z)) < 0 => return res!
            ldLoader.zstack.splice(idx, 1)
          @root.map ~> it.style.zIndex = ""
        res!

  ldLoader <<< do
    zstack: []
    set-zmgr: -> @zmgr = it

  window.ldLoader = ldLoader
)!
