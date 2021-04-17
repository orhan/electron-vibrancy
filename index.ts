var Vibrancy = require("bindings")("Vibrancy");
import { BrowserWindow } from "electron";

interface ViewOptions {
  material?: string;
  x: number;
  y: number;
  width: number;
  height: number;
  resizeMask?: number;
  maskImagePath?: string;
  viewId?: number;
  effectState?: string;
}

function AddView(buffer, options: ViewOptions) {
  var viewOptions = {
    Material: options.material,
    Position: { x: options.x, y: options.y },
    Size: { width: options.width, height: options.height },
    ResizeMask: options.resizeMask,
    MaskImagePath: options.maskImagePath,
    EffectState: options.effectState,
  };

  return Vibrancy.AddView(buffer, viewOptions);
}

function RemoveView(buffer, viewId: number) {
  var viewOptions = { ViewId: viewId };
  return Vibrancy.RemoveView(buffer, viewOptions);
}

function UpdateView(buffer, options: ViewOptions) {
  var viewOptions = {
    Material: options.material,
    Position: { x: options.x, y: options.y },
    Size: { width: options.width, height: options.height },
    ViewId: options.viewId,
    EffectState: options.effectState,
  };
  return Vibrancy.UpdateView(buffer, viewOptions);
}

function DisableVibrancy(buffer) {
  Vibrancy.SetVibrancy(false, buffer);
}

const electronVibrancy = {
  setVibrancy: function (window: BrowserWindow, options: ViewOptions) {
    if (window == null) {
      return -1;
    }

    var width = window.getSize()[0];
    var height = window.getSize()[1];

    if (options.material === null || typeof options.material === "undefined") {
      options.material = "appearance-based";
    }

    if (
      options.effectState === null ||
      typeof options.effectState === "undefined"
    ) {
      options.effectState = "follow-window";
    }

    var resizeMask = 2; //auto resize on both axis

    var viewOptions: ViewOptions = {
      material: options.material,
      width,
      height,
      x: 0,
      y: 0,
      resizeMask,
      maskImagePath: options.maskImagePath,
      effectState: options.effectState,
    };

    return AddView(window.getNativeWindowHandle(), viewOptions);
  },
  addView: function (window: BrowserWindow, options: ViewOptions) {
    return AddView(window.getNativeWindowHandle(), options);
  },
  updateView: function (window: BrowserWindow, options: ViewOptions) {
    return UpdateView(window.getNativeWindowHandle(), options);
  },
  removeView: function (window: BrowserWindow, viewId: number) {
    return RemoveView(window.getNativeWindowHandle(), viewId);
  },
  disableVibrancy: function (window: BrowserWindow) {
    return DisableVibrancy(window.getNativeWindowHandle());
  },
};

export default electronVibrancy;
