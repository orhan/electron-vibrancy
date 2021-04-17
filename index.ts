var Vibrancy = require("bindings")("Vibrancy");
import { BrowserWindow } from "electron";

interface ViewOptions {
  material?: number;
  x: number;
  y: number;
  width: number;
  height: number;
  resizeMask?: number;
  maskImagePath?: string;
  viewId?: number;
}

function AddView(buffer, options: ViewOptions) {
  var viewOptions = {
    Material: options.material,
    Position: { x: options.x, y: options.y },
    Size: { width: options.width, height: options.height },
    ResizeMask: options.resizeMask,
    MaskImagePath: options.maskImagePath,
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
  };
  return Vibrancy.UpdateView(buffer, viewOptions);
}

function DisableVibrancy(buffer) {
  Vibrancy.SetVibrancy(false, buffer);
}

const electronVibrancy = {
  setVibrancy: function (
    window: BrowserWindow,
    material: number,
    maskImagePath?: string
  ) {
    if (window == null) {
      return -1;
    }

    var width = window.getSize()[0];
    var height = window.getSize()[1];

    if (material === null || typeof material === "undefined") {
      material = 0;
    }

    var resizeMask = 2; //auto resize on both axis

    var viewOptions: ViewOptions = {
      material,
      width,
      height,
      x: 0,
      y: 0,
      resizeMask,
      maskImagePath,
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
