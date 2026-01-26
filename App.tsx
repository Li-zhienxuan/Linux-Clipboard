
import React, { useState, useEffect, useCallback, useMemo, useRef } from 'react';
import { Search, Plus, Loader2, Sparkles, Filter, Trash2, Clipboard, Scissors, CheckCircle2, Command, AlertCircle, Calendar, CalendarDays, History, Clock, LayoutGrid, ChevronRight, X } from 'lucide-react';
import { ClipboardItem, ContentType, TimeMode } from './types';
import { ClipboardCard } from './components/ClipboardCard';
import { analyzeImage, suggestTags } from './services/geminiService';

const App: React.FC = () => {
  const [items, setItems] = useState<ClipboardItem[]>([]);
  const [searchQuery, setSearchQuery] = useState('');
  const [filterType, setFilterType] = useState<ContentType | 'all'>('all');
  
  // Time Filter State
  const [timeMode, setTimeMode] = useState<TimeMode>('all');
  const [timeValue, setTimeValue] = useState<string | number | null>(null);

  const [isProcessing, setIsProcessing] = useState(false);
  const [activeTab, setActiveTab] = useState<'history' | 'starred'>('history');
  const [showToast, setShowToast] = useState<{message: string, type: 'info' | 'error'} | null>(null);
  
  const searchInputRef = useRef<HTMLInputElement>(null);

  // Constants for Time Filtering - Precision labels as requested
  const monthOptions = [
    "Jan 1", "Feb 2", "Mar 3", "Apr 4", "May 5", "Jun 6", 
    "Jul 7", "Aug 8", "Sep 9", "Oct 10", "Nov 11", "Dec 12"
  ];
  
  const weekOptions = [
    "Mon 周一", "Tue 周二", "Wed 周三", "Thu 周四", 
    "Fri 周五", "Sat 周六", "Sun 周日"
  ];

  const yearOptions = useMemo(() => {
    // Setting fixed year range 2026-2036 (11 years)
    return Array.from({ length: 11 }, (_, i) => 2026 + i);
  }, []);

  useEffect(() => {
    const saved = localStorage.getItem('smart_clipboard_items');
    if (saved) {
      setItems(JSON.parse(saved));
    }
  }, []);

  useEffect(() => {
    localStorage.setItem('smart_clipboard_items', JSON.stringify(items));
  }, [items]);

  // CORE FUNCTION: Add item with AI Indexing (Preserved)
  const handleAddItem = async (content: string, type: ContentType, blob?: string) => {
    if (items.some(i => i.content === (blob || content))) return;

    setIsProcessing(true);
    try {
      let tags: string[] = [type];
      let description = '';

      if (type === 'image' && blob) {
        const result = await analyzeImage(blob);
        tags = [...tags, ...result.tags];
        description = result.description;
      } else {
        const textTags = await suggestTags(content);
        tags = [...tags, ...textTags];
      }

      const newItem: ClipboardItem = {
        id: Date.now().toString(),
        type,
        content: blob || content,
        description,
        timestamp: Date.now(),
        tags: Array.from(new Set(tags)),
        isFavorite: false
      };

      setItems(prev => [newItem, ...prev]);
      notify("Indexed successfully!");
    } catch (error) {
      console.error("Indexing failed:", error);
      notify("AI index failed", 'error');
    } finally {
      setIsProcessing(false);
    }
  };

  const notify = (msg: string, type: 'info' | 'error' = 'info') => {
    setShowToast({ message: msg, type });
    setTimeout(() => setShowToast(null), 3000);
  };

  // CORE FUNCTION: Clipboard Processor (Preserved)
  const processClipboardData = (clipboardData: DataTransfer | null) => {
    if (!clipboardData) return;
    for (const item of Array.from(clipboardData.items)) {
      if (item.type.startsWith('image/')) {
        const file = item.getAsFile();
        if (file) {
          const reader = new FileReader();
          reader.onloadend = () => handleAddItem('Pasted Image', 'image', reader.result as string);
          reader.readAsDataURL(file);
        }
      } else if (item.type === 'text/plain') {
        item.getAsString((text) => {
          const type: ContentType = text.includes('http') ? 'link' : (text.includes('{') || text.includes('npm') ? 'code' : 'text');
          handleAddItem(text, type);
        });
      }
    }
  };

  // Listen for background paste events (Preserved)
  useEffect(() => {
    const handlePaste = (e: ClipboardEvent) => {
      const isSearchFocused = document.activeElement === searchInputRef.current;
      if (!isSearchFocused || (e.clipboardData && e.clipboardData.files.length > 0)) {
        if (!isSearchFocused) e.preventDefault();
        processClipboardData(e.clipboardData);
      }
    };
    window.addEventListener('paste', handlePaste);
    return () => window.removeEventListener('paste', handlePaste);
  }, [items]);

  const readClipboard = async () => {
    try {
      const clipboardItems = await navigator.clipboard.read();
      for (const item of clipboardItems) {
        const imageType = item.types.find(t => t.startsWith('image/'));
        if (imageType) {
          const blob = await item.getType(imageType);
          const reader = new FileReader();
          reader.onloadend = () => handleAddItem('Pasted Image', 'image', reader.result as string);
          reader.readAsDataURL(blob);
        } else if (item.types.includes('text/plain')) {
          const blob = await item.getType('text/plain');
          const text = await blob.text();
          const type: ContentType = text.includes('http') ? 'link' : (text.includes('{') || text.includes('npm') ? 'code' : 'text');
          handleAddItem(text, type);
        }
      }
    } catch (err) {
      notify("Clipboard permission required", 'error');
    }
  };

  const isInSpecificTimeRange = (timestamp: number) => {
    if (timeMode === 'all') return true;
    if (timeValue === null) return true;

    const date = new Date(timestamp);
    
    if (timeMode === 'year') return date.getFullYear() === Number(timeValue);
    
    if (timeMode === 'month') {
      return monthOptions[date.getMonth()] === timeValue;
    }
    
    if (timeMode === 'week') {
      const dayIndex = date.getDay(); // Sun is 0, Mon is 1...
      const normalizedIndex = dayIndex === 0 ? 6 : dayIndex - 1; // Mon is 0, Sun is 6
      return weekOptions[normalizedIndex] === timeValue;
    }

    return true;
  };

  const filteredItems = useMemo(() => {
    return items.filter(item => {
      const q = searchQuery.toLowerCase();
      const matchesSearch = 
        item.content.toLowerCase().includes(q) ||
        item.description?.toLowerCase().includes(q) ||
        item.tags.some(t => t.toLowerCase().includes(q));
      
      const matchesFilter = filterType === 'all' || item.type === filterType;
      const matchesTab = activeTab === 'history' || (activeTab === 'starred' && item.isFavorite);
      const matchesTime = isInSpecificTimeRange(item.timestamp);

      return matchesSearch && matchesFilter && matchesTab && matchesTime;
    });
  }, [items, searchQuery, filterType, activeTab, timeMode, timeValue]);

  const groupedItems = useMemo(() => {
    const groups: { [key: string]: ClipboardItem[] } = {};
    filteredItems.forEach(item => {
      const date = new Date(item.timestamp);
      const dateStr = date.toLocaleDateString(undefined, { 
        weekday: 'long', year: 'numeric', month: 'long', day: 'numeric' 
      });
      if (!groups[dateStr]) groups[dateStr] = [];
      groups[dateStr].push(item);
    });
    return groups;
  }, [filteredItems]);

  return (
    <div className="flex flex-col h-full text-white overflow-hidden relative selection:bg-blue-500/30">
      {/* Search Header */}
      <div className="p-8 pb-4 bg-gray-900/40 backdrop-blur-3xl border-b border-white/5 relative z-40">
        <div className="max-w-4xl mx-auto w-full space-y-6">
          <div className="flex items-center justify-between">
            <div className="flex bg-white/5 p-1 rounded-2xl border border-white/10 shadow-inner">
              {(['history', 'starred'] as const).map(tab => (
                <button 
                  key={tab}
                  onClick={() => setActiveTab(tab)}
                  className={`px-8 py-2 rounded-xl text-[10px] font-black uppercase tracking-[0.2em] transition-all duration-300 ${activeTab === tab ? 'bg-white/10 text-white shadow-lg ring-1 ring-white/10' : 'text-gray-500 hover:text-gray-300'}`}
                >
                  {tab}
                </button>
              ))}
            </div>
            
            <button 
              onClick={readClipboard}
              className="flex items-center gap-2 px-4 py-2 bg-blue-600/10 hover:bg-blue-600/20 border border-blue-500/20 rounded-2xl transition-all"
            >
              <Clipboard className="w-3.5 h-3.5 text-blue-400" />
              <span className="text-[10px] font-black uppercase tracking-widest text-blue-400">Sync Now</span>
            </button>
          </div>

          <div className="relative group">
            <Search className={`absolute left-6 top-1/2 -translate-y-1/2 w-7 h-7 transition-colors duration-500 ${searchQuery ? 'text-blue-500' : 'text-gray-600'}`} />
            <input
              ref={searchInputRef}
              type="text"
              placeholder="Query history or image concepts..."
              className="w-full pl-16 pr-20 py-6 bg-white/5 border border-white/10 rounded-[32px] focus:outline-none focus:ring-4 focus:ring-blue-500/10 focus:border-blue-500/30 transition-all text-2xl placeholder:text-gray-700 shadow-inner"
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
            />
          </div>

          {/* Hierarchical Smart Toolbar */}
          <div className="flex flex-col gap-4">
            <div className="flex items-center gap-6">
              <div className="flex items-center gap-2">
                <LayoutGrid className="w-4 h-4 text-gray-700 mr-1" />
                {(['all', 'text', 'image', 'code'] as const).map(type => (
                  <button
                    key={type}
                    onClick={() => setFilterType(type)}
                    className={`px-4 py-1.5 rounded-full text-[9px] font-black uppercase tracking-widest transition-all ${filterType === type ? 'text-blue-400 bg-blue-500/10' : 'text-gray-600 hover:text-gray-400'}`}
                  >
                    {type}
                  </button>
                ))}
              </div>

              <div className="h-4 w-[1px] bg-white/5" />

              <div className="flex items-center gap-2">
                <History className="w-4 h-4 text-gray-700 mr-1" />
                <div className="flex items-center bg-white/5 p-1 rounded-xl border border-white/10">
                  {(['all', 'year', 'month', 'week'] as const).map(mode => (
                    <button
                      key={mode}
                      onClick={() => { setTimeMode(mode); setTimeValue(null); }}
                      className={`px-4 py-1.5 rounded-lg text-[9px] font-black uppercase tracking-widest transition-all ${timeMode === mode ? 'bg-white/10 text-white shadow-inner' : 'text-gray-600 hover:text-gray-400'}`}
                    >
                      {mode === 'all' ? '全部' : mode === 'year' ? '年' : mode === 'month' ? '月' : '周'}
                    </button>
                  ))}
                </div>
              </div>
            </div>

            {/* Level 2 context filter with exact labels */}
            {timeMode !== 'all' && (
              <div className="flex items-center gap-2 bg-blue-500/5 p-2.5 rounded-2xl border border-blue-500/10 animate-in overflow-x-auto no-scrollbar whitespace-nowrap scroll-smooth">
                <ChevronRight className="w-4 h-4 text-blue-500/40 flex-shrink-0" />
                {(timeMode === 'year' ? yearOptions : timeMode === 'month' ? monthOptions : weekOptions).map(option => (
                  <button
                    key={option}
                    onClick={() => setTimeValue(option)}
                    className={`px-4 py-1.5 rounded-xl text-[10px] font-bold transition-all flex-shrink-0 ${
                      timeValue === option 
                        ? 'bg-blue-600 text-white shadow-lg shadow-blue-900/40' 
                        : 'text-gray-500 hover:text-gray-300 hover:bg-white/5'
                    }`}
                  >
                    {option}{timeMode === 'year' ? '年' : ''}
                  </button>
                ))}
                {timeValue && (
                  <button 
                    onClick={() => setTimeValue(null)}
                    className="ml-auto p-1.5 bg-red-500/10 hover:bg-red-500/20 text-red-400 rounded-lg transition-colors flex-shrink-0"
                  >
                    <X className="w-3.5 h-3.5" />
                  </button>
                )}
              </div>
            )}
          </div>
        </div>
      </div>

      {/* Content Area */}
      <div className="flex-grow overflow-y-auto custom-scrollbar bg-black/20">
        {isProcessing && (
          <div className="flex items-center justify-center py-4 gap-3 bg-blue-600/5 backdrop-blur-md sticky top-0 z-30 border-b border-blue-500/10">
            <Loader2 className="w-4 h-4 animate-spin text-blue-400" />
            <span className="text-[10px] font-black uppercase tracking-[0.4em] text-blue-400">AI INDEXING ENGINE ACTIVE</span>
            <Sparkles className="w-3 h-3 text-yellow-500 animate-pulse" />
          </div>
        )}

        <div className="max-w-4xl mx-auto w-full py-6">
          {Object.keys(groupedItems).length > 0 ? (
            Object.entries(groupedItems).map(([date, itemsForDate]) => (
              <div key={date} className="mb-10 animate-in">
                <div className="px-8 py-4 sticky top-0 bg-gray-950/40 backdrop-blur-sm z-10 flex items-center gap-4">
                  <Calendar className="w-3.5 h-3.5 text-gray-700" />
                  <h3 className="text-[10px] font-black uppercase tracking-[0.3em] text-gray-500">
                    {date}
                  </h3>
                  <div className="flex-grow h-[1px] bg-white/5" />
                  <span className="text-[9px] font-bold text-gray-800">{itemsForDate.length} items</span>
                </div>
                <div className="flex flex-col">
                  {itemsForDate.map((item, idx) => (
                    <ClipboardCard 
                      key={item.id}
                      item={item} 
                      onCopy={(i) => {
                        navigator.clipboard.writeText(i.content);
                        notify("Added to clipboard");
                      }}
                      onDelete={(id) => setItems(prev => prev.filter(i => i.id !== id))}
                      onToggleFavorite={(id) => setItems(prev => prev.map(i => i.id === id ? { ...i, isFavorite: !i.isFavorite } : i))}
                      onJumpToTime={(i) => {
                        const d = new Date(i.timestamp);
                        const yr = d.getFullYear();
                        if (yr >= 2026 && yr <= 2036) {
                          setTimeMode('year');
                          setTimeValue(yr);
                        } else {
                          setTimeMode('month');
                          setTimeValue(monthOptions[d.getMonth()]);
                        }
                        notify(`Focused on records from ${yr}`);
                      }}
                    />
                  ))}
                </div>
              </div>
            ))
          ) : (
            <div className="flex flex-col items-center justify-center h-[50vh] opacity-20">
              <Command className="w-16 h-16 mb-6" />
              <p className="text-[10px] font-black uppercase tracking-[0.4em]">Empty Stack in this period</p>
            </div>
          )}
        </div>
      </div>

      {/* Toast Notification */}
      {showToast && (
        <div className={`absolute bottom-24 left-1/2 -translate-x-1/2 z-50 ${showToast.type === 'error' ? 'bg-red-600' : 'bg-blue-600'} text-white px-6 py-3 rounded-2xl shadow-2xl flex items-center gap-3 animate-in ring-1 ring-white/20`}>
          {showToast.type === 'error' ? <AlertCircle className="w-4 h-4" /> : <CheckCircle2 className="w-4 h-4" />}
          <span className="text-[10px] font-black uppercase tracking-widest">{showToast.message}</span>
        </div>
      )}

      {/* Status Bar */}
      <div className="px-10 py-6 border-t border-white/5 bg-gray-950/80 flex items-center justify-between text-[10px] font-black uppercase tracking-[0.2em] text-gray-600">
        <div className="flex gap-10">
          <span className="flex items-center gap-2 group cursor-default">
            <span className="bg-white/5 px-2 py-1 rounded border border-white/5 group-hover:text-white transition-colors">⌘ K</span> Quick Focus
          </span>
          <span className="flex items-center gap-2 group cursor-default">
            <span className="bg-white/5 px-2 py-1 rounded border border-white/5 group-hover:text-white transition-colors">⌘ V</span> Direct Add
          </span>
        </div>
        <div className="flex items-center gap-6">
           {timeValue && (
             <span className="text-blue-500/60 animate-pulse">Filtering: {timeValue}</span>
           )}
           <span className="text-gray-800">SMART CLIPBOARD PRO V2</span>
        </div>
      </div>
    </div>
  );
};

export default App;
