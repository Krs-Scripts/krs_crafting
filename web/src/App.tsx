import { useState } from 'react';
import CraftingMenu from './components/CraftingMenu';
import { useNuiEvent } from './hooks/useNuiEvent';
import { MantineProvider } from '@mantine/core';

const App = () => {
  const [visible, setVisible] = useState(false);

  useNuiEvent<boolean>('setVisible', setVisible);

  if (!visible) return null;

  return (
    <MantineProvider defaultColorScheme="dark">
      <CraftingMenu />
    </MantineProvider>
  );
};

export default App;