// src/App.jsx
import React from "react";
import './input.css';
import ConnectWallet from "./components/ConnectWallet";
import FieldValidators from './components/FieldValidators';

function App() {
  return (
    <div>
      <h1>NutriChain React test</h1>
      <ConnectWallet />
      <FieldValidators />
    </div>
  );
}

export default App;
