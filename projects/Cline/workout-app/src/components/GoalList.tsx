import React, { useState } from 'react';
import { useGoals } from '@/context/GoalsContext';
import { useWorkouts } from '@/context/WorkoutsContext';

interface GoalListProps {
  selectedDate: Date | null;
}

const GoalList = ({ selectedDate }: GoalListProps) => {
  const { goals, fetchGoals } = useGoals();
  const { workouts } = useWorkouts();
  const [editingGoalId, setEditingGoalId] = useState<string | null>(null);
  const [editedDescription, setEditedDescription] = useState('');
  const [editedTarget, setEditedTarget] = useState(0);
  const [editedProgress, setEditedProgress] = useState(0);

  const handleDelete = async (id: string) => {
    const response = await fetch(`/api/goals/${id}`, {
      method: 'DELETE',
    });

    if (response.ok) {
      fetchGoals(null);
    } else {
      console.error('Failed to delete goal');
    }
  };

  const handleUpdate = async (id: string) => {
    const response = await fetch(`/api/goals/${id}`, {
      method: 'PUT',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        description: editedDescription,
        target: editedTarget,
        progress: editedProgress,
      }),
    });

    if (response.ok) {
      fetchGoals(null);
      setEditingGoalId(null);
    } else {
      console.error('Failed to update goal');
    }
  };

  const filteredGoals = selectedDate
    ? goals.filter((goal) => {
        const workout = workouts.find(workout => workout.id === goal.workout_id);
        if (workout) {
          const workoutDate = new Date(workout.date).toDateString();
          return workoutDate === selectedDate.toDateString();
        }
        return false;
      })
    : goals;

  return (
    <div className="bg-gray-800 p-4 rounded-lg shadow-md">
      <h2 className="text-xl font-bold">Goals</h2>

      <ul>
        {Array.isArray(filteredGoals) ? (
          filteredGoals.map((goal) => {
            const workout = workouts.find(workout => workout.id === goal.workout_id);
            return (
              <li key={goal.id} className="flex items-center justify-between py-2 border-b border-gray-700">
                {editingGoalId === goal.id ? (
                  <>
                    <input
                      type="text"
                      value={editedDescription}
                      onChange={(e) => setEditedDescription(e.target.value)}
                      className="bg-background text-foreground rounded mr-2"
                    />
                    <input
                      type="number"
                      value={editedTarget}
                      onChange={(e) => setEditedTarget(Number(e.target.value))}
                      className="bg-background text-foreground rounded mr-2"
                    />
                    <input
                      type="number"
                      value={editedProgress}
                      onChange={(e) => setEditedProgress(Number(e.target.value))}
                      className="bg-background text-foreground rounded mr-2"
                    />
                    <button onClick={() => handleUpdate(goal.id)} className="bg-blue-500 text-white p-2 rounded mr-2">Save</button>
                    <button onClick={() => setEditingGoalId(null)} className="bg-gray-500 text-white p-2 rounded">Cancel</button>
                  </>
                ) : (
                  <>
                    <div>
                      <p className="font-bold">{goal.description}</p>
                      <p>Target: {goal.target}</p>
                      <p>Progress: {goal.progress}</p>
                      <p>Workout date: {workout ? workout.date : 'Date not found'}</p>
                    </div>
                    <div>
                      <button onClick={() => {
                        setEditingGoalId(goal.id);
                        setEditedDescription(goal.description);
                        setEditedTarget(goal.target);
                        setEditedProgress(goal.progress);
                      }} className="bg-blue-500 text-white p-2 rounded mr-2">Update</button>
                      <button onClick={() => handleDelete(goal.id)} className="bg-red-500 text-white p-2 rounded">Delete</button>
                    </div>
                  </>
                )}
              </li>
            );
          })
        ) : (
          <li>No goals yet!</li>
        )}
      </ul>
    </div>
  );
};

export default GoalList;
