import { LitElement, html, css } from 'lit';
import termStyle from '../styles/termStyle';
import { ref, createRef } from 'lit/directives/ref.js';

export class LitTerminal extends LitElement {
  declare inputValue: string;
  declare history: Array<string>;
  declare headerText: Array<string>;
  static get properties() {
    return {
      inputValue: { type: String },
      history: { type: Array },
      headerText: { type: Array },
    };
  }
  terminalElement = createRef<HTMLDivElement>();
  terminalInputElement = createRef<HTMLInputElement>();
  // @query(".terminal") terminalElement;

  constructor() {
    super();
    this.inputValue = ''; // Initialize your property
    // @ts-ignore
    this.history = ['\n'];
    this.headerText = [
      'Archetypal Tech welcomes you to DEATH',
      'well possibly...',
      '\n',
      "The O'Ruggin Trail, no:23",
      'from the good folk at',
    ];
  }

  // @ts-ignore
  static styles = css([termStyle]);
  static inputHistory: Array<string> = [];
  static inputHistoryIndex = 0;
  static inputHistoryOriginalInput = '';

  render() {
    return html`
      <div class="terminal" ${ref(this.terminalElement)} @click="${this.focusOnInput}">
        ${this.headerText.map((line) => html`<div class="headerOutput">${line}</div>`)}
        <div class="bastard"><b>B</b>est <b>A</b>rchetypal <b>S</b>ystem <b>T</b>erminals <b>A</b>nd <b>R</b>etrograde <b>D</b>evices</div>
        ${this.history.map((line) => html`<div class="output">${line}</div>`)}
        <span>&#x3e; </spawn><input type="text" .value="${this.inputValue}" ${ref(this.terminalInputElement)}
                  @keydown="${this.handleEnter}"
                  @input=${this.handleInput}>
      </div>
    `;
  }

  private handleInput(e: Event) {
    const input = e.target as HTMLInputElement;
    const elem = e.target as EventTarget;
    let newVal = input.value;
    // @ts-ignore
    if (this.inputValue === newVal && this.inputValue !== (elem as HTMLInputElement).value) {
      (elem as HTMLInputElement).value = this.inputValue;
    } else {
      this.inputValue = newVal;
    }
  }

  private focusOnInput(e: Event) {
    this.terminalInputElement.value.focus();
  }

  public scrollToBottom() {
    if (this.terminalElement) {
      this.terminalElement.value.scrollTo(
        0,
        this.terminalElement.value.scrollHeight,
        // smooth
        { behavior: 'smooth' }
      );
    }
  }

  private stripCommandString(s: string) {
    let seq = '> ';
    return s.replace(seq, '');
  }

  private handleEnter(e: KeyboardEvent) {
    if (e.key === 'Enter') {
      const commandStr = this.stripCommandString(this.inputValue);
      this.dispatchEvent(
        new CustomEvent('command-update', {
          detail: { value: commandStr },
          bubbles: true, // Allows the event to bubble up through the DOM
          composed: true, // Allows the event to cross the shadow DOM boundary
        })
      );
      this.history = [...this.history, '> ' + commandStr];
      this.inputValue = '';
      LitTerminal.inputHistory.push(commandStr);
      LitTerminal.inputHistoryIndex = 0;
      LitTerminal.inputHistoryOriginalInput = '';
    } else if (e.key === 'ArrowUp') {
      /* Example of how the input history up/down works
      array index, action, inputHistoryIndex
    ===================
      0 look around 3
      1 go west     2
      2 go south    1
      
      > User input  0

    ===================

      0 look around 1
      
      > User input  0
      */
      if (LitTerminal.inputHistoryIndex === 0) {
        LitTerminal.inputHistoryOriginalInput = this.inputValue; // store the original input
      }
      if (LitTerminal.inputHistoryIndex < LitTerminal.inputHistory.length) {
        LitTerminal.inputHistoryIndex++;
        this.inputValue = LitTerminal.inputHistory[LitTerminal.inputHistory.length - LitTerminal.inputHistoryIndex];
      }
    } else if (e.key === 'ArrowDown') {
      if (LitTerminal.inputHistoryIndex > 0) {
        LitTerminal.inputHistoryIndex--;
        if (LitTerminal.inputHistoryIndex === 0) {
          this.inputValue = LitTerminal.inputHistoryOriginalInput; // restore the original input
        } else {
          this.inputValue = LitTerminal.inputHistory[LitTerminal.inputHistory.length - LitTerminal.inputHistoryIndex];
        }
      }
    }
  }
}
customElements.define('l-terminal', LitTerminal);
