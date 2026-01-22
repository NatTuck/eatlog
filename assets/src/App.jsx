import Counter from './components/Counter';

function App() {
  return (
    <div style={{ padding: '2rem', fontFamily: 'system-ui, sans-serif' }}>
      <h1 style={{ fontSize: '1.5rem', fontWeight: 'bold', marginBottom: '1rem' }}>
        EatLog
      </h1>
      <Counter />
    </div>
  );
}

export default App;
