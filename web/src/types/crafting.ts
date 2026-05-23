// src/types/crafting.ts

export interface Ingredient {
  name: string;
  label: string;
  amount: number;
  owned?: number; // Add this line
}

export interface CraftableItem {
  name: string;
  label: string;
  description: string;
  image: string;
  ingredients: Ingredient[];
  duration: number; // tempo in ms per craftare
}

// Puoi aggiungere anche l'interfaccia per i dati che ricevi dal NUI
export interface NuiCraftingData {
  items: CraftableItem[];
  workshopName?: string;
}