import java.awt.datatransfer.*; 
import java.awt.Toolkit;

import java.util.ArrayList;

ArrayList<String> lines = new ArrayList<>();

int currentLine = 0;
int currentPos = 0;

color selectionColor = color (100);

long startTime = millis();
boolean isShowing;

boolean showCtrlA;

int startPos, startLine;
boolean isSelection;

int getCursorPosition() {
  float x = 100;
  currentPos = 0;
  for (int i = 0; i <= lines.get(currentLine).length(); i++) {
    float textWidthAtI = textWidth(lines.get(currentLine).substring(0, i));
    if (mouseX < x + textWidthAtI + 5) {
      if (lines.get(currentLine).length() >= i) return i;
    }
  }
  return lines.get(currentLine).length();
}

int getCursorLine() {
   float y = 100;
  for (int i = 0; i < lines.size(); i++) {
    float textWidthAtI = 20 * i; // textWidth(lines.get(currentLine).substring(0, i))
    if (mouseY < y + textWidthAtI) {
      return i;
    }
  }
  return lines.size() - 1;
}

void mouseDragged() {
  if (!isSelection) {
    isSelection = true;
    startPos = currentPos;
    startLine = currentLine;
  }
  currentLine = getCursorLine();
  currentPos = getCursorPosition();
}

void mouseReleased() {
  // something
}

void setup() {
  size(800, 600);
  //textSize(20);
  lines.add("");
  
  PFont font;
  
  font = createFont("JetBrainsMono-Regular.ttf", 20);
  textFont(font);
  
}

void resetCursor() {
  startTime = millis();
  isShowing = true;
}

void mousePressed() {
  currentLine = getCursorLine();
  currentPos = getCursorPosition();
  resetCursor();
  showCtrlA = false;
  isSelection = false;
}

void drawCursor() {
  // textWidth(lines.get(currentLine))
  fill(255);
  rect(100 + textWidth(lines.get(currentLine).substring(0, currentPos)), 86 + currentLine * 20, 1, 15);
}

void drawText() {
  textAlign(LEFT);
  for (int i = 0; i < lines.size(); i++) {
    text(lines.get(i), 100, 100 + i * 20);
  }
}

void drawLinesCount() {
  textAlign(RIGHT);
  for (int i = 0; i < lines.size(); i++) {
    fill(150);
    text(i + 1, 90, 100 + i * 20);
  }
}

void fetchCtrlA() {
  if (showCtrlA) {
    isSelection = false;
      for (int i = lines.size() - 1; i > 0; i--) {
        lines.remove(i);
        currentPos = 0;
      }
      lines.set(0, "");
      currentPos = 0;
      showCtrlA = false;
      currentLine = 0;
   }
}

boolean fetchSel() {
  if (isSelection) {
      fetchSelection();
      return true;
  }
  return false;
}

void keyTyped() {
  
  if (key == BACKSPACE) {
    if (fetchSel()) return;
    String currentText = lines.get(currentLine);
    
    fetchCtrlA();
    
    if (currentText.length() > 0 && currentPos > 0) {
      lines.set(currentLine, currentText.substring(0, currentText.substring(0, currentPos).length() - 1) + currentText.substring(currentPos));
      currentPos -= 1;
    } else if (currentLine > 0 && currentPos == 0) {
      int prevPos = lines.get(currentLine - 1).length();
      lines.set(currentLine - 1, lines.get(currentLine - 1) + currentText);
      lines.set(currentLine, "");
      currentLine -= 1;
      currentPos = prevPos;
      lines.remove(currentLine + 1);
    }
    
  } else if (key != CODED && key != ENTER && key != TAB && !keyEvent.isControlDown() && !keyEvent.isAltDown()) {
    fetchSel();
    fetchCtrlA();
    lines.set(currentLine, lines.get(currentLine).substring(0, currentPos) + key + lines.get(currentLine).substring(currentPos));
    currentPos += 1;
    if (key == '{') {
      lines.set(currentLine, lines.get(currentLine).substring(0, currentPos) + "}" + lines.get(currentLine).substring(currentPos));
    }
  } else if (key == TAB) {
    fetchSel();
    fetchCtrlA();
    lines.set(currentLine, lines.get(currentLine).substring(0, currentPos) + "    " + lines.get(currentLine).substring(currentPos));
    currentPos += 4;
  }
  
  startTime = millis();
  isShowing = true;
}

void drawDebug(String text) {
   text(text, 300, 300);
}

void copyToClipboard(String str) {
  StringSelection stringSelection = new StringSelection(str);
  Clipboard clipboard = Toolkit.getDefaultToolkit().getSystemClipboard();
  clipboard.setContents(stringSelection, null);
}

int getCountOfSpaces() {
  String text = lines.get(currentLine);
  int counter = 0;
  
  for (char i : text.toCharArray()) {
     if (i == ' ') counter++;
     else break;
  }
  
  return counter;
}

void keyPressed() {
  
  println((int)key, keyCode);
  
  if ((int)key == 22 && keyCode == 86) {
    fetchSel();
    fetchCtrlA();
    
    String text = getClipboardText();
    
    String currentText = lines.get(currentLine);
    
    String[] texts = split(text, "\n");
    int endCurrentLine = currentLine;
    int prevPos = currentPos;
    
    for (int i = 0; i < texts.length; i++) {
      
      if (currentLine + i < lines.size()) {
        if (i == 0) {
          lines.set(currentLine + i, currentText.substring(0, prevPos) + texts[i]);
        } else {
          lines.set(currentLine + i, texts[i]);
        }
      } else {
        lines.add("");
        lines.set(currentLine + i, texts[i]);
      }
      
      if (i == 0) {
        currentPos = texts[i].length() + currentText.substring(0, prevPos).length();
      } else {
        currentPos = texts[i].length();
      }
      endCurrentLine = currentLine + i;
      
    }
    
    currentLine = endCurrentLine;
    
    lines.set(currentLine, lines.get(currentLine) + currentText.substring(prevPos));
  }
  
  if ((int)key == 1 && keyCode == 65) {
    showCtrlA = !showCtrlA;
  }
  
  if (!keyEvent.isShiftDown() && (keyCode == UP || keyCode == LEFT || keyCode == RIGHT || keyCode == DOWN)) {
    showCtrlA = false;
  }
  
  if ((int)key == 3 && keyCode == 67) {
    if (!showCtrlA) return;
    
    StringBuilder output = new StringBuilder();
    
    for (String line : lines) {
      output.append(line + "\n"); 
    }
    
    output.deleteCharAt(output.toString().length() - 1);
    
    copyToClipboard(output.toString());
  }
  
  if (key == ENTER) {
    fetchSel();
    fetchCtrlA();
    //lines.add("");
    if (lines.get(currentLine).startsWith(" ")) {
       int countOfSpaces = getCountOfSpaces();
       String string = "";
       for (int i = 0; i < countOfSpaces; i++) {
         string += " "; 
       }
       lines.add(currentLine + 1, string + lines.get(currentLine).substring(currentPos));
       lines.set(currentLine, lines.get(currentLine).substring(0, currentPos));
       currentPos = countOfSpaces;
    } else {
      lines.add(currentLine + 1, lines.get(currentLine).substring(currentPos));
      lines.set(currentLine, lines.get(currentLine).substring(0, currentPos));
      currentPos = 0;
    }
    currentLine += 1;
    resetCursor();
  }
  
  if (keyCode == LEFT) {
    if (currentPos > 0) currentPos -= 1;
    else {
      if (currentLine > 0) {
        currentPos = lines.get(currentLine - 1).length();
        currentLine -= 1;
      }
    }
    resetCursor();
  }
  
  if (keyCode == RIGHT) {
    if (currentPos < lines.get(currentLine).length()) currentPos += 1;
    else if (currentLine < lines.size() - 1) {
      currentPos = 0;
      currentLine += 1;
    }
    resetCursor();
  }
  
  if (keyCode == UP) {
    if (currentLine > 0) {
      currentLine -= 1;
      if (currentPos > lines.get(currentLine).length()) {
         currentPos = lines.get(currentLine).length();
      }
    }
    resetCursor();
  }
  
  if (keyCode == DOWN) {
    if (currentLine + 1 < lines.size()) {
      currentLine += 1;
      if (currentPos > lines.get(currentLine).length()) {
         currentPos = lines.get(currentLine).length();
      }
    }
    resetCursor();
  }
  
}

String getClipboardText() {
  String text = "";
  try {
    Clipboard clipboard = Toolkit.getDefaultToolkit().getSystemClipboard();
    Transferable contents = clipboard.getContents(null);
    if (contents != null && contents.isDataFlavorSupported(DataFlavor.stringFlavor)) {
      text = (String) contents.getTransferData(DataFlavor.stringFlavor);
    }
  } catch (Exception e) {
    e.printStackTrace();
  }
  return text;
}

void drawBeautifulLine() {
  fill(50);
  rect(93, 85, 2, lines.size() * 20);
}

void selectCtrlA() {
  if (showCtrlA) {
    for (int i = 0; i < lines.size(); i++) {
      fill(selectionColor);
      rect(100, 85 + i * 20, textWidth(lines.get(i)), 20);
    }
  }
}

void selectSelected() {
  if (isSelection) {
    if (startLine <= currentLine) {
      for (int i = startLine; i <= currentLine; i++) {
        fill(selectionColor);
        if (startLine == currentLine) {
          rect(100 + textWidth(lines.get(i).substring(0, startPos)), 85 + i * 20, textWidth(lines.get(i)) - textWidth(lines.get(i).substring(currentPos)) - textWidth(lines.get(i).substring(0, startPos)), 20);
          continue; 
        }
        if (i == startLine) rect(100 + textWidth(lines.get(i).substring(0, startPos)), 85 + i * 20, textWidth(lines.get(i)) - textWidth(lines.get(i).substring(0, startPos)), 20);
        else if (i != startLine && i != currentLine) rect(100, 85 + i * 20, textWidth(lines.get(i)), 20);
        else if (i == currentLine) rect(100, 85 + i * 20, textWidth(lines.get(i)) - textWidth(lines.get(i).substring(currentPos)), 20);
      }
    } else {
      for (int i = currentLine; i <= startLine; i++) {
        fill(selectionColor);
        if (startLine == currentLine) {
          rect(100 + textWidth(lines.get(i).substring(0, startPos)), 85 + i * 20, textWidth(lines.get(i)) - textWidth(lines.get(i).substring(currentPos)) - textWidth(lines.get(i).substring(0, startPos)), 20);
          continue; 
        }
        if (i == startLine) rect(100, 85 + i * 20, textWidth(lines.get(i)) - textWidth(lines.get(i).substring(startPos)), 20);
        else if (i != startLine && i != currentLine) rect(100, 85 + i * 20, textWidth(lines.get(i)), 20);
        else if (i == currentLine) rect(100 + textWidth(lines.get(i).substring(0, currentPos)), 85 + i * 20, textWidth(lines.get(i)) - textWidth(lines.get(i).substring(0, currentPos)), 20);
      } 
    }
  }
}

void fetchSelection() {
   if (isSelection) {
     isSelection = false;
     if (startLine <= currentLine) {
       ArrayList<Integer> linesToRemove = new ArrayList<>();
       
       int lastCurrentPos = currentPos;
       int lastCurrentLine = currentLine;
       
       for (int i = startLine; i <= currentLine; i++) {
          if (startLine == currentLine) {
            String line = lines.get(currentLine);
            lines.set(currentLine, line.substring(0, startPos) + line.substring(currentPos));
            currentPos = line.substring(0, startPos).length();
            continue;
          }
          
           if (i == startLine) {
             String line = lines.get(startLine);
             lines.set(startLine, line.substring(0, startPos));
             currentPos = line.substring(0, startPos).length();
           } else if (i != lastCurrentLine && i != startLine) {
            lines.set(i, "");
            linesToRemove.add(0, i);
            currentPos = 0;
           } else if (i == lastCurrentLine) {
             String line = lines.get(i).substring(lastCurrentPos);
             
             lines.remove(currentLine);
             
             currentPos = lines.get(startLine).length();
             currentLine = startLine;
             
             lines.set(currentLine, lines.get(currentLine) + line);
             
           }
           
       }
       
       for (int line : linesToRemove) {
         println(line);
         if (line < lines.size()) lines.remove(line);
         else lines.remove(lines.size() - 1);
       }
     } else {
       int t1 = startPos;
       int t2 = startLine;
       
       startPos = currentPos;
       startLine = currentLine;
       currentPos = t1;
       currentLine = t2;
       
       ArrayList<Integer> linesToRemove = new ArrayList<>();
       
       int lastCurrentPos = currentPos;
       int lastCurrentLine = currentLine;
       
       for (int i = startLine; i <= currentLine; i++) {
          if (startLine == currentLine) {
            String line = lines.get(currentLine);
            lines.set(currentLine, line.substring(0, startPos) + line.substring(currentPos));
            currentPos = line.substring(0, startPos).length();
            continue;
          }
          
           if (i == startLine) {
             String line = lines.get(startLine);
             lines.set(startLine, line.substring(0, startPos));
             currentPos = line.substring(0, startPos).length();
           } else if (i != lastCurrentLine && i != startLine) {
            lines.set(i, "");
            linesToRemove.add(0, i);
            currentPos = 0;
           } else if (i == lastCurrentLine) {
             String line = lines.get(i).substring(lastCurrentPos);
             
             lines.remove(currentLine);
             
             currentPos = lines.get(startLine).length();
             currentLine = startLine;
             
             lines.set(currentLine, lines.get(currentLine) + line);
             
           }
           
       }
       
       for (int line : linesToRemove) {
         println(line);
         if (line < lines.size()) lines.remove(line);
         else lines.remove(lines.size() - 1);
       } 
     }
   }
}

void draw() {
  background(40);
  noStroke();
  
  selectCtrlA();
  selectSelected();
  
  drawLinesCount();
  drawBeautifulLine();
  
  fill(220);
  
  drawText();
  drawDebug(String.format("CurrentPos: %d" + 
  "\nCurrentLine: %d\nLines: %d\nStartPos: %d\nStartLine: %d\nIsSelection: %b", currentPos, currentLine, lines.size(), startPos, startLine, isSelection));
  
  if (millis() - startTime > 500) {
    isShowing = !isShowing;
    startTime = millis();
  }
  
  if (isShowing) drawCursor();
  
}
