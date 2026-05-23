import { useEffect, useRef } from 'react';

import { noop } from '../utils/misc';

interface NuiMessageData<T = unknown> {
  action: string;
  data: T;
}

type NuiHandler<T> = (data: T) => void;

export const useNuiEvent = <T>(
  action: string,
  handler: NuiHandler<T>,
) => {
  const savedHandler = useRef<NuiHandler<T>>(noop);

  useEffect(() => {
    savedHandler.current = handler;
  }, [handler]);

  useEffect(() => {
    const listener = (
      event: MessageEvent<NuiMessageData<T>>,
    ) => {
      const { action: eventAction, data } = event.data;

      if (eventAction !== action) return;

      savedHandler.current(data);
    };

    window.addEventListener('message', listener);

    return () => {
      window.removeEventListener('message', listener);
    };
  }, [action]);
};