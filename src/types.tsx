
export type ContentType = 'text' | 'image' | 'link' | 'code';

export type TimeMode = 'all' | 'year' | 'month' | 'week';

export type ClipboardItem = {
  id: string;
  type: ContentType;
  content: string; // text content or base64 image
  description?: string; // AI generated description for images
  timestamp: number;
  tags: string[];
  isFavorite: boolean;
};

export type AppState = {
  items: ClipboardItem[];
  searchQuery: string;
  filterType: ContentType | 'all';
  timeMode: TimeMode;
  timeValue: string | number | null;
  isProcessing: boolean;
};
