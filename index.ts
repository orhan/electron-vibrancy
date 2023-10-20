var Vibrancy = require("bindings")("Vibrancy");
import { BrowserWindow } from "electron";

export interface Dimensions {
  x: number;
  y: number;
  width: number;
  height: number;
}

export interface EffectOptions {
  material?: string;
  resizeMask?: number;
  viewId?: number;
  effectState?: string;
  blendingMode?: string;
  isEmphasized?: boolean;
  cornerRadius?: number;
  maskImagePath?: string;
  maskImageInsets?: {
    top: number;
    left: number;
    bottom: number;
    right: number;
  };
}

type Options = Dimensions & EffectOptions;

function AddView(buffer, options: Options) {
  var viewOptions = {
    Material: options.material,
    Position: { x: options.x, y: options.y },
    Size: { width: options.width, height: options.height },
    ResizeMask: options.resizeMask,
    EffectState: options.effectState,
    BlendingMode: options.blendingMode,
    IsEmphasized: options.isEmphasized,
    MaskImagePath: options.maskImagePath,
    MaskImageInsets: options.maskImageInsets,
    CornerRadius: options.cornerRadius,
  };

  return Vibrancy.AddView(buffer, viewOptions);
}

function RemoveView(buffer, viewId: number) {
  return Vibrancy.RemoveView(buffer, viewId);
}

function UpdateView(buffer, viewId: number, options: Options) {
  var viewOptions = {
    Material: options.material,
    Position: { x: options.x, y: options.y },
    Size: { width: options.width, height: options.height },
    ResizeMask: options.resizeMask,
    EffectState: options.effectState,
    BlendingMode: options.blendingMode,
    IsEmphasized: options.isEmphasized,
    MaskImagePath: options.maskImagePath,
    MaskImageInsets: options.maskImageInsets,
    CornerRadius: options.cornerRadius,
  };

  return Vibrancy.UpdateView(buffer, viewId, viewOptions);
}

function DisableVibrancy() {
  Vibrancy.DisableVibrancy();
}

const assignOptions = (
  dimensions: Dimensions,
  effectOptions: EffectOptions
): Options => {
  if (
    effectOptions.material === null ||
    typeof effectOptions.material === "undefined"
  ) {
    effectOptions.material = "appearance-based";
  }

  if (
    effectOptions.effectState === null ||
    typeof effectOptions.effectState === "undefined"
  ) {
    effectOptions.effectState = "follow-window";
  }

  if (
    effectOptions.blendingMode === null ||
    typeof effectOptions.blendingMode === "undefined"
  ) {
    effectOptions.blendingMode = "behind-window";
  }

  if (
    effectOptions.isEmphasized === null ||
    typeof effectOptions.isEmphasized === "undefined"
  ) {
    effectOptions.isEmphasized = false;
  }

  var resizeMask = 2; //auto resize on both axis

  var viewOptions: Options = {
    material: effectOptions.material,
    width: dimensions.width,
    height: dimensions.height,
    x: dimensions.x,
    y: dimensions.y,
    resizeMask,
    effectState: effectOptions.effectState,
    blendingMode: effectOptions.blendingMode,
    isEmphasized: effectOptions.isEmphasized,
    maskImagePath: effectOptions.maskImagePath,
    maskImageInsets: effectOptions.maskImageInsets,
    cornerRadius: effectOptions.cornerRadius,
  };

  return viewOptions;
};

const electronVibrancy = {
  setVibrancy: function (window: BrowserWindow, effectOptions: EffectOptions) {
    if (window == null) {
      return -1;
    }

    let dimensions: Dimensions = {
      width: window.getSize()[0],
      height: window.getSize()[1],
      x: 0,
      y: 0,
    };

    let nativeOptions = assignOptions(dimensions, effectOptions);
    return AddView(window.getNativeWindowHandle(), nativeOptions);
  },
  addView: function (
    window: BrowserWindow,
    dimensions: Dimensions,
    effectOptions: EffectOptions
  ) {
    var nativeOptions: Options = assignOptions(dimensions, effectOptions);
    return AddView(window.getNativeWindowHandle(), nativeOptions);
  },
  updateView: function (
    window: BrowserWindow,
    viewId: number,
    dimensions: Dimensions,
    effectOptions: EffectOptions
  ) {
    var nativeOptions: Options = assignOptions(dimensions, effectOptions);
    return UpdateView(window.getNativeWindowHandle(), viewId, nativeOptions);
  },
  removeView: function (window: BrowserWindow, viewId: number) {
    return RemoveView(window.getNativeWindowHandle(), viewId);
  },
  disableVibrancy: function () {
    return DisableVibrancy();
  },
};

export default electronVibrancy;
