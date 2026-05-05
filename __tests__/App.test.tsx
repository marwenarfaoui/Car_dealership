/**
 * @format
 */

import React from 'react';
import { render } from '@testing-library/react-native';
import App from '../App';

describe('App Component', () => {
  it('affiche l\'écran principal correctement', async () => {
    const { getByText } = render(<App />);
    const welcomeElement = getByText(/Welcome to React Native/i);
    expect(welcomeElement).toBeTruthy();
  });

  it('rend l\'application sans erreur', () => {
    const { getByTestId } = render(<App />);
    expect(getByTestId('app-container')).toBeTruthy();
  });

  test('renders correctly', async () => {
    const { getByText } = render(<App />);
    expect(getByText(/Welcome/i)).toBeTruthy();
  });
});

