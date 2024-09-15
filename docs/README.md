# Noriyo Akita's Today I Learned
This is website from [https://github.com/noriyotcp/til](noriyotcp/til)

## Articles

{% for page in site.pages %}
  {% if page.path != 'README.md' %}
    - {{ page.path }} [{{ page.title | default: page.basename }}]({{ page.url | relative_url }})
  {% elsif page.url == '/docs/'%}
    <!-- Debugging Information -->
    Path: {{ page.path }}
    Title: {{ page.title or default: page.basename }}
    URL: {{ page.url or relative_url }}
  {% endif %}
{% endfor %}

