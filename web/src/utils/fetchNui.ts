import { isEnvBrowser } from './misc';

type NuiResponse<T> = T;

export async function fetchNui<TResponse>(
  eventName: string,
  data?: unknown,
  mockData?: TResponse,
): Promise<NuiResponse<TResponse>> {
  if (isEnvBrowser() && mockData) {
    return mockData;
  }

  const resourceName =
    window.GetParentResourceName?.() ?? 'nui-frame-app';

  const response = await fetch(
    `https://${resourceName}/${eventName}`,
    {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: JSON.stringify(data ?? {}),
    },
  );

  if (!response.ok) {
    throw new Error(
      `Failed to fetch NUI callback "${eventName}"`,
    );
  }

  return response.json();
}