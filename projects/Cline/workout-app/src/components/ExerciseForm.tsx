import React, { useState } from 'react';

const ExerciseForm = () => {
  const [name, setName] = useState('');
  const [description, setDescription] = useState('');

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();

    const response = await fetch('/api/exercises', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({ name, description }),
    });

    if (response.ok) {
      // Handle success
      console.log('Exercise created successfully');
      setName('');
      setDescription('');
    } else {
      // Handle error
      console.error('Failed to create exercise');
    }
  };

  return (
    <form onSubmit={handleSubmit} className="container mx-auto mt-8">
      <h3 className="text-2xl font-bold mb-4">Create Exercise</h3>
      <div className="mb-4">
        <label htmlFor="name" className="block text-white text-sm font-bold mb-2">
          Name:
        </label>
        <input
          type="text"
          id="name"
          className="shadow appearance-none border rounded w-full py-2 px-3 text-gray-700 leading-tight focus:outline-none focus:shadow-outline"
          value={name}
          onChange={(e) => setName(e.target.value)}
        />
      </div>
      <div className="mb-4">
        <label htmlFor="description" className="block text-white text-sm font-bold mb-2">
          Description:
        </label>
        <textarea
          id="description"
          className="shadow appearance-none border rounded w-full py-2 px-3 text-gray-700 leading-tight focus:outline-none focus:shadow-outline"
          value={description}
          onChange={(e) => setDescription(e.target.value)}
        />
      </div>
      <button
        type="submit"
        className="bg-blue-500 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded focus:outline-none focus:shadow-outline"
      >
        Create
      </button>
    </form>
  );
};

export default ExerciseForm;
