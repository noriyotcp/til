import { describe, it, beforeEach, expect } from 'vitest';
import { setupBackToHotkeys } from '../setupBackToHotkeys';

describe('setupBackToHotkeys', () => {
  beforeEach(() => {
    document.body.innerHTML = '';
  });

  it('should set data-hotkey attribute for links with numeric content', () => {
    document.body.innerHTML = `
      <a class="back-to-top" href="#2024-10">Link 1</a>
      <a class="back-to-top" href="#2024">Link 2</a>
    `;

    setupBackToHotkeys();

    const links = document.querySelectorAll('a.back-to-top');
    expect(links[0].getAttribute('data-hotkey')).toBe('b 2 0 2 4 1 0');
    expect(links[1].getAttribute('data-hotkey')).toBe('b 2 0 2 4');
  });

  it('should set data-hotkey attribute for links with page-title content', () => {
    document.body.innerHTML = `
      <a class="back-to-top" href="#page-title">Link 1</a>
    `;

    setupBackToHotkeys();

    const link = document.querySelector('a.back-to-top');
    expect(link.getAttribute('data-hotkey')).toBe('b t');
  });

  it('should not set data-hotkey attribute for links with non-matching content', () => {
    document.body.innerHTML = `
      <a class="back-to-top" href="#non-matching">Link 1</a>
    `;

    setupBackToHotkeys();

    const link = document.querySelector('a.back-to-top');
    expect(link.getAttribute('data-hotkey')).toBe('undefined');
  });

  it('should not set data-hotkey attribute if href does not contain #', () => {
    document.body.innerHTML = `
      <a class="back-to-top" href="no-hash">Link 1</a>
    `;

    setupBackToHotkeys();

    const link = document.querySelector('a.back-to-top');
    expect(link.getAttribute("data-hotkey")).toBeNull();
  });

  it('should handle multiple links correctly', () => {
    document.body.innerHTML = `
      <a class="back-to-top" href="#2024-10">Link 1</a>
      <a class="back-to-top" href="#page-title">Link 2</a>
      <a class="back-to-top" href="#non-matching">Link 3</a>
    `;

    setupBackToHotkeys();

    const links = document.querySelectorAll('a.back-to-top');
    expect(links[0].getAttribute('data-hotkey')).toBe('b 2 0 2 4 1 0');
    expect(links[1].getAttribute('data-hotkey')).toBe('b t');
    expect(links[2].getAttribute('data-hotkey')).toBe('undefined');
  });

  it('should handle links with mixed content', () => {
    document.body.innerHTML = `
      <a class="back-to-top" href="#123-abc">Link 1</a>
      <a class="back-to-top" href="#page-title-456">Link 2</a>
    `;

    setupBackToHotkeys();

    const links = document.querySelectorAll('a.back-to-top');
    expect(links[0].getAttribute('data-hotkey')).toBe('b 1 2 3 a b c');
    expect(links[1].getAttribute('data-hotkey')).toBe('undefined');
  });
});
