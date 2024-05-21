const cssString: string = `:host {
          display: block;
          margin: 0;
      }

      textarea {
          color: forestgreen;
          background: black;
          outline: none;
          border: black;
          font-family: 'Courier', sans-serif;
          font-size: 16px;
          width: 100%;
          box-sizing: border-box;
      }

      input {
          color: forestgreen;
          width: 90%;
          background: black;
          outline: none;
          border: black;
          font-family: 'Courier', sans-serif;
          font-size: 16px;
          box-sizing: border-box;
          margin-bottom: 8px;
          margin-left: 4px;
          margin-right: 4px;
      }

      .bastard {
          color: forestgreen;
          font-family: 'Courier', sans-serif;
          font-size: 12px;
          width: 80%;
          margin-left: auto;
          margin-right: auto;
          margin-bottom: 4px;
          text-align: center;
          white-space: pre-wrap;
      }

      .terminal {
          color: forestgreen;
          background: black;
          border: 1px solid chartreuse;
          border-radius: 4px;
          font-family: 'Courier', sans-serif;
          font-size: 16px;
          margin-top: 4px;
          margin-bottom: 4px;
          height: calc(100% - 8px);
          height: 100%;
          overflow-y: auto;
          scroll-behavior: smooth;
      }

      .output {
          width: 80%;
          margin-left: auto;
          margin-right: auto;
          margin-top: 8px;
          margin-bottom: 8px;
          text-align: left;
          white-space: pre-wrap;
      }

      .headerOutput {
          width: 80%;
          margin-left: auto;
          margin-right: auto;
          text-align: center;
          white-space: pre-wrap;
      }
`;
export default cssString;
