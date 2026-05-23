export const isEnvBrowser = (): boolean =>
  !window.invokeNative;

export const noop = (): void => {};