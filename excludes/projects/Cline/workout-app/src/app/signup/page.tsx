import { signup } from '@/app/signup/actions';

const SignupPage = () => {
  return (
    <form>
      <label htmlFor="email">Email:</label>
      <input id="email" name="email" type="email" required />
      <label htmlFor="firstName">First Name:</label>
      <input id="firstName" name="firstName" type="text" required />
      <label htmlFor="lastName">Last Name:</label>
      <input id="lastName" name="lastName" type="text" required />
      <label htmlFor="password">Password:</label>
      <input id="password" name="password" type="password" required />
      <button formAction={signup}>Sign up</button>
    </form>
  )
}

export default SignupPage;
