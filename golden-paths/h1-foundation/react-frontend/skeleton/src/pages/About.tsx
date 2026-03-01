function About() {
  return (
    <div>
      <h1>About</h1>
      <p>
        <strong>${{ values.name }}</strong> is a React application built with TypeScript and Vite,
        scaffolded by the Three Horizons Accelerator platform.
      </p>
      <ul>
        <li>React 18 with TypeScript</li>
        <li>Vite for fast development and optimized builds</li>
        <li>React Router for client-side navigation</li>
        <li>Vitest for unit testing</li>
        <li>ESLint for code quality</li>
      </ul>
    </div>
  );
}

export default About;
