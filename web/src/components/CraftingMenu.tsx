import { 
  Box, 
  Container, 
  Flex, 
  Text, 
  Button, 
  ActionIcon, 
  Group, 
  Divider, 
  Stack, 
  Center,
  NumberInput,
  ScrollArea 
} from "@mantine/core";
import { useState, useEffect } from "react";
import { fetchNui } from "../utils/fetchNui";
import { useNuiEvent } from "../hooks/useNuiEvent";
import { CraftableItem, Ingredient } from "../types/crafting"; 
import { IoIosBackspace } from "react-icons/io";
import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";
import { faHammer, faClock, faLayerGroup } from "@fortawesome/free-solid-svg-icons";

const UI_FONT = "'Inter', -apple-system, BlinkMacSystemFont, sans-serif";

interface Locales {
  workbench: string;
  subtitle: string;
  available: string;
  required: string;
  total_for: string;
  quantity: string;
  time_left: string;
  total_time: string;
  crafting: string;
  start: string;
  select: string;
}

export default function CraftingMenu() {
  const [items, setItems] = useState<CraftableItem[]>([]);
  const [selectedItem, setSelectedItem] = useState<CraftableItem | null>(null);
  const [isCrafting, setIsCrafting] = useState(false);
  const [timeLeft, setTimeLeft] = useState<number>(0);
  const [craftAmount, setCraftAmount] = useState<number>(1);
  const [locales, setLocales] = useState<Locales>({
    workbench: "WORKBENCH",
    subtitle: "Select a blueprint to start production",
    available: "Available",
    required: "REQUIRED COMPONENTS",
    total_for: "Total for x",
    quantity: "CRAFT QUANTITY",
    time_left: "TIME REMAINING:",
    total_time: "TOTAL TIME:",
    crafting: "CRAFTING...",
    start: "START PRODUCTION",
    select: "Select a blueprint to begin"
  });

  useNuiEvent("loadCrafting", (data: { items: CraftableItem[], locales: Locales }) => {
    setItems(data.items);
    if (data.locales) setLocales(data.locales); 
    setSelectedItem(null);
    setIsCrafting(false);
    setTimeLeft(0);
    setCraftAmount(1);
  });

 useNuiEvent("updateItems", (data: { items: CraftableItem[], locales?: Locales }) => {
    setItems(data.items);
    if (data.locales) {
      setLocales(data.locales);
    }
    setSelectedItem((prev) => {
      if (!prev) return null;
      return data.items.find(i => i.name === prev.name) || prev;
    });
  });

  useEffect(() => {
    let timer: ReturnType<typeof setInterval> | undefined;

    if (isCrafting && timeLeft > 0) {
      timer = setInterval(() => {
        setTimeLeft((prev) => {
          if (prev <= 0.1) {
            setIsCrafting(false);
            return 0;
          }
          return prev - 0.1;
        });
      }, 100);
    }

    return () => {
      if (timer) clearInterval(timer);
    };
  }, [isCrafting, timeLeft]);

  useEffect(() => {
    setCraftAmount(1);
  }, [selectedItem]);

  const handleClose = () => {
    if (isCrafting) return; 
    fetchNui("hide-ui");
  };

  const handleStartCraft = () => {
    if (!selectedItem || isCrafting) return;
    
    fetchNui("startCrafting", { 
        item: selectedItem.name, 
        amount: craftAmount 
    }).then((success) => {
      if (success) {
        setIsCrafting(true);
        setTimeLeft((selectedItem.duration * craftAmount) / 1000);
      } else {
        setIsCrafting(false);
      }
    }).catch(() => {
      setIsCrafting(false);
    });
  };

  return (
    <Box style={{ 
      position: 'absolute', top: 0, left: 0, width: '100vw', height: '100vh', 
      display: 'flex', justifyContent: 'center', alignItems: 'center', zIndex: 100, 
      fontFamily: UI_FONT, background: 'rgba(0,0,0,0.6)' 
    }}>
      <style>
        {`
          @keyframes jellySoft {
            0% { transform: scale(1, 1); }
            30% { transform: scale(1.02, 0.98); }
            50% { transform: scale(0.99, 1.01); }
            100% { transform: scale(1, 1); }
          }
          .jelly-hover:hover {
            animation: jellySoft 0.4s ease-in-out;
          }
        `}
      </style>

      <Container w={900} h={600} p={0} bg="#121212" style={{ 
        borderRadius: "12px", border: '1px solid #2a2a2a', overflow: 'hidden', 
        display: 'flex', flexDirection: 'column', boxShadow: '0 20px 25px -5px rgba(0, 0, 0, 0.5)'
      }}>
        
        <Group justify="space-between" p="md" bg="#1a1a1a" style={{ borderBottom: '1px solid #2a2a2a', zIndex: 10 }}>
          <Group>
            <Box bg="#228be6" p={8} style={{ borderRadius: '8px', display: 'flex' }}>
              <FontAwesomeIcon icon={faHammer} color="white" />
            </Box>
            <Stack gap={0}>
              <Text c="white" fw={700} size="lg" style={{ lineHeight: 1 }}>{locales.workbench}</Text>
              <Text c="dimmed" size="xs">{locales.subtitle}</Text>
            </Stack>
          </Group>
         <ActionIcon 
            variant="transparent" 
            onClick={handleClose} 
            disabled={isCrafting}
            size="lg"
            className="jelly-hover"
            styles={{
              root: {
                backgroundColor: 'transparent',
                border: 'none',
                '&:hover': {
                  backgroundColor: 'transparent'
                }
              }
            }}
          >
            <IoIosBackspace size={32} color="#228be6" />
          </ActionIcon>
        </Group>

        <Flex style={{ flexGrow: 1, overflow: 'hidden' }}>
          
          <Box 
            style={{ 
              width: '350px', 
              height: '100%', 
              borderRight: '1px solid #2a2a2a',
              padding: '15px', 
              display: 'flex',
              flexDirection: 'column'
            }} 
            bg="#141414"
          >
            <ScrollArea h="100%" scrollbarSize={0} styles={{ viewport: { borderRadius: '8px' } }}>
              <Stack gap="sm">
                {items.map((item) => (
                  <Box
                    key={item.name}
                    className="jelly-hover"
                    onClick={() => !isCrafting && setSelectedItem(item)}
                    style={{
                      padding: '12px', 
                      borderRadius: 12, 
                      cursor: isCrafting ? 'not-allowed' : 'pointer',
                      backgroundColor: selectedItem?.name === item.name ? '#0099ff2c' : '#1a1a1a',
                      transition: 'background-color 0.2s ease', 
                      opacity: isCrafting && selectedItem?.name !== item.name ? 0.5 : 1,
                    }}
                  >
                    <Group>
                      <Box w={45} h={45} bg="#222" style={{ borderRadius: '12px', display: 'flex', justifyContent: 'center', alignItems: 'center' }}>
                          <img src={item.image} style={{ width: '80%', height: '80%', objectFit: 'contain' }} alt={item.label} />
                      </Box>
                      <Stack gap={0}>
                        <Text c="white" fw={600} size="sm">{item.label}</Text>
                        <Text c="dimmed" size="xs">{locales.available}</Text>
                      </Stack>
                    </Group>
                  </Box>
                ))}
              </Stack>
            </ScrollArea>
          </Box>

          <Box style={{ flex: 1, padding: '25px', display: 'flex', flexDirection: 'column' }} bg="#111">
            {selectedItem ? (
              <Stack justify="space-between" h="100%">
                <Box>
                  <Group justify="space-between" align="flex-start">
                    <Box style={{ flex: 1 }}>
                      <Text c="white" size="xl" fw={800}>{selectedItem.label.toUpperCase()}</Text>
                      <Text c="gray.5" size="sm" mb="xl">{selectedItem.description}</Text>
                    </Box>
                    <Box w={80} h={80} bg="#1a1a1a" style={{ borderRadius: '12px', display: 'flex', justifyContent: 'center', alignItems: 'center' }}>
                      <img src={selectedItem.image} style={{ width: '70%' }} alt={selectedItem.label} />
                    </Box>
                  </Group>
                  
                  <Group justify="space-between" mb="xs">
                    <Text c="gray.6" fw={700} size="xs" style={{ letterSpacing: '1px' }}>{locales.required}</Text>
                    <Text c="dimmed" size="xs">{locales.total_for}{craftAmount}</Text>
                  </Group>

                  <Stack gap={8}>
                    {selectedItem.ingredients.map((ing: Ingredient) => (
                      <Group key={ing.name} justify="space-between" p="10px" bg="#1a1a1a" style={{ borderRadius: '12px' }}>
                        <Group gap="sm">
                          <Box w={6} h={6} bg="#228be6" style={{ borderRadius: '50%' }} />
                          <Text c="gray.3" size="sm">{ing.label}</Text>
                        </Group>
                        <Text c={(ing.owned ?? 0) >= (ing.amount * craftAmount) ? "white" : "red.5"} fw={700} size="sm">
                          {ing.owned ?? 0}/{ing.amount * craftAmount}
                        </Text>
                      </Group>
                    ))}
                  </Stack>
                </Box>

                <Box>
                  <Divider mb="lg" color="#2a2a2a" />
                  
                  {!isCrafting && (
                    <Group mb="md" justify="space-between">
                        <Group gap="xs">
                            <FontAwesomeIcon icon={faLayerGroup} color="#666" size="sm" />
                            <Text c="gray.6" size="xs" fw={600}>{locales.quantity}</Text>
                        </Group>
                    <NumberInput
                      value={craftAmount}
                      onChange={(val) => {
                          let stringVal = String(val).replace(/[^0-9]/g, ''); 
                          let num = Number(stringVal) || 1;
                          if (num > 100) num = 100;
                          setCraftAmount(num);
                      }}
                      onKeyDown={(e) => {
                          const target = e.target as HTMLInputElement;
                          const isControlKey = ['Backspace', 'Delete', 'ArrowLeft', 'ArrowRight', 'Tab'].includes(e.key) || e.ctrlKey || e.metaKey;
                          if (target.value.length >= 3 && !isControlKey && target.selectionStart === target.selectionEnd) {
                              e.preventDefault(); 
                          }
                      }}
                      min={1}
                      max={100}
                      maxLength={3}
                      size="xs"
                      w={80}
                      styles={{
                          input: { backgroundColor: '#1a1a1a', border: 'none', color: 'white', textAlign: 'center' },
                          control: { border: 'none', color: 'white' }
                      }}
                  />
                    </Group>
                  )}

                  <Group gap="xs" mb="lg">
                    <FontAwesomeIcon icon={faClock} color="#666" size="sm" />
                    <Text c="gray.6" size="xs" fw={600}>
                      {isCrafting 
                        ? `${locales.time_left} ${timeLeft.toFixed(1)}s` 
                        : `${locales.total_time} ${((selectedItem.duration * craftAmount) / 1000).toFixed(1)}s`}
                    </Text>
                  </Group>

                  <Button 
                    fullWidth 
                    color="blue" 
                    size="xl" 
                    onClick={handleStartCraft}
                    loading={isCrafting} 
                    disabled={isCrafting}
                    className="jelly-hover"
                    leftSection={<FontAwesomeIcon icon={faHammer} />}
                    styles={{ root: { height: '55px', borderRadius: '12px' } }}
                  >
                    {isCrafting ? locales.crafting : `${locales.start} (x${craftAmount})`}
                  </Button>
                </Box>
              </Stack>
            ) : (
              <Center h="100%">
                <Stack align="center" gap="xs">
                  <FontAwesomeIcon icon={faHammer} size="3x" color="#2a2a2a" />
                  <Text c="dimmed" size="sm">{locales.select}</Text>
                </Stack>
              </Center>
            )}
          </Box>
        </Flex>
      </Container>
    </Box>
  );
}