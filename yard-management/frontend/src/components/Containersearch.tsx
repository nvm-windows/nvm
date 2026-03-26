import { useState, useMemo, useRef, useEffect } from "react";
import { Input } from "@/components/ui/input";
import { Search, X } from "lucide-react";
import { getAllContainerNumbers, findContainerByNumber } from "@/lib/containerData";
import type { Container } from "@shared/schema";

interface ContainerSearchProps {
  onContainerSelect: (container: Container, bay: string, level: string) => void;
  onClear: () => void;
}

export function ContainerSearch({ onContainerSelect, onClear }: ContainerSearchProps) {
  const [searchValue, setSearchValue] = useState("");
  const [isOpen, setIsOpen] = useState(false);
  const [selectedIndex, setSelectedIndex] = useState(-1);
  const containerRef = useRef<HTMLDivElement>(null);
  const inputRef = useRef<HTMLInputElement>(null);

  const allContainerNumbers = useMemo(() => getAllContainerNumbers(), []);

  const filteredContainers = useMemo(() => {
    if (!searchValue.trim()) return [];
    const query = searchValue.toUpperCase();
    return allContainerNumbers
      .filter((no) => no.includes(query))
      .slice(0, 10); // Limit to 10 results
  }, [searchValue, allContainerNumbers]);

  // Close dropdown when clicking outside
  useEffect(() => {
    const handleClickOutside = (event: MouseEvent) => {
      if (containerRef.current && !containerRef.current.contains(event.target as Node)) {
        setIsOpen(false);
      }
    };

    document.addEventListener("mousedown", handleClickOutside);
    return () => document.removeEventListener("mousedown", handleClickOutside);
  }, []);

  const handleSelect = (containerNo: string) => {
    const result = findContainerByNumber(containerNo);
    if (result) {
      setSearchValue(containerNo);
      setIsOpen(false);
      onContainerSelect(result.container, result.bay, result.level);
    }
  };

  const handleClear = () => {
    setSearchValue("");
    setIsOpen(false);
    setSelectedIndex(-1);
    onClear();
    inputRef.current?.focus();
  };

  const handleKeyDown = (e: React.KeyboardEvent) => {
    if (!isOpen) {
      if (e.key === "ArrowDown" && filteredContainers.length > 0) {
        setIsOpen(true);
        setSelectedIndex(0);
      }
      return;
    }

    switch (e.key) {
      case "ArrowDown":
        e.preventDefault();
        setSelectedIndex((prev) => 
          prev < filteredContainers.length - 1 ? prev + 1 : prev
        );
        break;
      case "ArrowUp":
        e.preventDefault();
        setSelectedIndex((prev) => (prev > 0 ? prev - 1 : 0));
        break;
      case "Enter":
        e.preventDefault();
        if (selectedIndex >= 0 && filteredContainers[selectedIndex]) {
          handleSelect(filteredContainers[selectedIndex]);
        }
        break;
      case "Escape":
        setIsOpen(false);
        setSelectedIndex(-1);
        break;
    }
  };

  return (
    <div ref={containerRef} className="relative w-64">
      <div className="relative">
        <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-muted-foreground" />
        <Input
          ref={inputRef}
          type="search"
          placeholder="Search containers..."
          value={searchValue}
          onChange={(e) => {
            setSearchValue(e.target.value);
            setIsOpen(e.target.value.length > 0);
            setSelectedIndex(-1);
          }}
          onFocus={() => {
            if (searchValue.length > 0 && filteredContainers.length > 0) {
              setIsOpen(true);
            }
          }}
          onKeyDown={handleKeyDown}
          className="pl-10 pr-8 bg-card"
          data-testid="input-search"
        />
        {searchValue && (
          <button
            type="button"
            onClick={handleClear}
            className="absolute right-3 top-1/2 -translate-y-1/2 text-muted-foreground hover:text-foreground transition-colors"
            data-testid="button-clear-search"
          >
            <X className="w-4 h-4" />
          </button>
        )}
      </div>

      {/* Autocomplete Dropdown */}
      {isOpen && filteredContainers.length > 0 && (
        <div className="absolute top-full left-0 right-0 mt-1 bg-card border rounded-md shadow-lg z-50 overflow-hidden">
          <ul className="max-h-60 overflow-auto custom-scrollbar">
            {filteredContainers.map((containerNo, index) => {
              const result = findContainerByNumber(containerNo);
              return (
                <li key={containerNo}>
                  <button
                    type="button"
                    onClick={() => handleSelect(containerNo)}
                    className={`w-full px-3 py-2 text-left text-sm flex items-center justify-between gap-2 transition-colors ${
                      index === selectedIndex 
                        ? "bg-primary/10 text-primary" 
                        : "hover:bg-muted"
                    }`}
                    data-testid={`search-result-${containerNo}`}
                  >
                    <span className="font-mono font-medium">{containerNo}</span>
                    {result && (
                      <span className="text-xs text-muted-foreground">
                        Bay {result.bay} | {result.level}
                      </span>
                    )}
                  </button>
                </li>
              );
            })}
          </ul>
        </div>
      )}

      {isOpen && searchValue.length > 0 && filteredContainers.length === 0 && (
        <div className="absolute top-full left-0 right-0 mt-1 bg-card border rounded-md shadow-lg z-50 p-3 text-center text-sm text-muted-foreground">
          No containers found
        </div>
      )}
    </div>
  );
}
