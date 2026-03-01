function Home() {
  return (
    <div>
      <h1>Welcome to ${{ values.name }}</h1>
      <p>${{ values.description }}</p>
      <p>
        Edit <code>src/pages/Home.tsx</code> to get started.
      </p>
    </div>
  );
}

export default Home;
