
import React from 'react';
import { ClipboardItem } from '../types';
import { Copy, Trash2, Star, Image as ImageIcon, FileText, Code, Link as LinkIcon, Clock, ExternalLink, Target } from 'lucide-react';

interface ClipboardCardProps {
  item: ClipboardItem;
  onCopy: (item: ClipboardItem) => void;
  onDelete: (id: string) => void;
  onToggleFavorite: (id: string) => void;
  onJumpToTime: (item: ClipboardItem) => void;
}

export const ClipboardCard: React.FC<ClipboardCardProps> = ({ item, onCopy, onDelete, onToggleFavorite, onJumpToTime }) => {
  const getIcon = () => {
    switch (item.type) {
      case 'image': return <ImageIcon className="w-4 h-4 text-blue-400/80" />;
      case 'code': return <Code className="w-4 h-4 text-emerald-400/80" />;
      case 'link': return <LinkIcon className="w-4 h-4 text-purple-400/80" />;
      default: return <FileText className="w-4 h-4 text-gray-400/80" />;
    }
  };

  const formatDate = (ts: number) => {
    const date = new Date(ts);
    return date.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit', hour12: false });
  };

  const getFullDate = (ts: number) => {
    return new Date(ts).toLocaleDateString(undefined, { 
      year: 'numeric', 
      month: 'short', 
      day: 'numeric' 
    });
  };

  return (
    <div className="group flex items-start gap-5 p-6 hover:bg-white/[0.03] border-b border-white/[0.03] transition-all duration-500 cursor-default relative overflow-hidden">
      {/* Type Icon */}
      <div className="flex-shrink-0 mt-1 p-2.5 bg-white/5 rounded-2xl border border-white/5 group-hover:bg-white/10 group-hover:border-blue-500/20 transition-all duration-500">
        {getIcon()}
      </div>
      
      <div className="flex-grow min-w-0">
        <div className="flex items-center justify-between mb-2.5">
          <div className="flex items-center gap-2">
            {item.isFavorite && (
              <span className="flex items-center gap-1 px-2 py-0.5 bg-yellow-500/10 rounded-full text-[9px] font-black text-yellow-500 uppercase tracking-tighter ring-1 ring-yellow-500/20">
                <Star className="w-2.5 h-2.5 fill-yellow-500" /> Pinned
              </span>
            )}
            <span className="text-[9px] uppercase font-black tracking-widest text-gray-500/80 py-0.5">
              {item.type}
            </span>
          </div>
          
          {/* Top-Right Interactive Timestamp */}
          <button 
            onClick={() => onJumpToTime(item)}
            className="flex items-center gap-1.5 opacity-20 group-hover:opacity-100 group-hover:text-blue-400 transition-all duration-500 cursor-pointer hover:bg-white/5 px-2 py-1 rounded-lg" 
            title={`Filter by this time: ${getFullDate(item.timestamp)}`}
          >
            <Clock className="w-3 h-3" />
            <span className="text-[10px] font-medium tabular-nums tracking-wider uppercase">
              {formatDate(item.timestamp)}
            </span>
            <Target className="w-2.5 h-2.5 opacity-0 group-hover:opacity-100 ml-1" />
          </button>
        </div>
        
        {item.type === 'image' ? (
          <div className="space-y-4">
            <div className="relative inline-block rounded-2xl overflow-hidden border border-white/10 group/img shadow-2xl">
              <img 
                src={item.content} 
                alt="clipping" 
                className="max-h-72 object-contain bg-black/40 group-hover/img:scale-[1.02] transition-transform duration-700 ease-out" 
              />
              <div className="absolute inset-0 bg-gradient-to-t from-black/80 via-transparent to-transparent opacity-0 group-hover/img:opacity-100 transition-all duration-500 flex items-end p-4">
                 <button onClick={() => onCopy(item)} className="bg-white/90 hover:bg-white text-black px-4 py-2 rounded-xl text-xs font-bold flex items-center gap-2 shadow-2xl active:scale-95 transition-all">
                    <Copy className="w-3.5 h-3.5" /> Copy Image
                 </button>
              </div>
            </div>
            {item.description && (
              <div className="relative pl-4 border-l-2 border-blue-500/30">
                <p className="text-sm text-gray-400 leading-relaxed font-medium italic">
                  {item.description}
                </p>
              </div>
            )}
          </div>
        ) : (
          <div className="relative">
            <p className={`text-[15px] leading-relaxed text-gray-200/90 font-medium whitespace-pre-wrap break-words ${item.type === 'code' ? 'font-mono bg-[#050505] p-5 rounded-2xl border border-white/5 text-emerald-400/80 text-sm shadow-inner' : ''}`}>
              {item.content}
            </p>
            {item.type === 'link' && (
              <a 
                href={item.content} 
                target="_blank" 
                rel="noopener noreferrer" 
                className="inline-flex items-center gap-1.5 mt-3 px-3 py-1.5 bg-blue-500/5 hover:bg-blue-500/10 border border-blue-500/20 rounded-lg text-blue-400 hover:text-blue-300 text-[10px] font-black uppercase tracking-widest transition-all group/link"
              >
                Follow Link <ExternalLink className="w-3 h-3 group-hover/link:translate-x-0.5 group-hover/link:-translate-y-0.5 transition-transform" />
              </a>
            )}
          </div>
        )}

        <div className="flex flex-wrap gap-1.5 mt-5">
          {item.tags.map(tag => (
            <span key={tag} className="px-2.5 py-1 text-[9px] font-black uppercase tracking-widest bg-white/5 text-gray-500 rounded-lg border border-white/5 hover:border-blue-500/30 hover:text-blue-400 transition-all cursor-pointer">
              {tag}
            </span>
          ))}
        </div>
      </div>

      {/* Quick Actions */}
      <div className="flex-shrink-0 flex flex-col gap-2 opacity-0 group-hover:opacity-100 transition-all translate-x-4 group-hover:translate-x-0 ml-4">
        <button 
          onClick={() => onCopy(item)}
          className="p-3 bg-white/5 hover:bg-blue-600 rounded-2xl text-gray-400 hover:text-white transition-all shadow-xl active:scale-90"
          title="Copy"
        >
          <Copy className="w-4 h-4" />
        </button>
        <button 
          onClick={() => onToggleFavorite(item.id)}
          className={`p-3 bg-white/5 hover:bg-yellow-500/20 rounded-2xl transition-all shadow-xl active:scale-90 ${item.isFavorite ? 'text-yellow-500' : 'text-gray-400'}`}
          title="Favorite"
        >
          <Star className={`w-4 h-4 ${item.isFavorite ? 'fill-yellow-500' : ''}`} />
        </button>
        <button 
          onClick={() => onDelete(item.id)}
          className="p-3 bg-white/5 hover:bg-red-500 rounded-2xl text-gray-400 hover:text-white transition-all shadow-xl active:scale-90"
          title="Delete"
        >
          <Trash2 className="w-4 h-4" />
        </button>
      </div>
    </div>
  );
};
