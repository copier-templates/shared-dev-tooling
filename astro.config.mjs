import { defineConfig } from 'astro/config';
import starlight from '@astrojs/starlight';
import starlightThemeRosePine from 'starlight-theme-rose-pine';

export default defineConfig({
  site: 'https://copier-templates.github.io',
  base: '/shared-dev-tooling/',
  integrations: [
    starlight({
      title: 'Shared Dev Tooling',
      description: 'Shared mise tasks and prek hooks.',
      plugins: [starlightThemeRosePine()],
      social: [
        {
          icon: 'github',
          label: 'GitHub',
          href: 'https://github.com/copier-templates/shared-dev-tooling',
        },
      ],
      sidebar: [
        {
          label: 'Guidelines',
          items: [{ autogenerate: { directory: 'guidelines' } }],
        },
        {
          label: 'Project',
          items: [
            { label: 'Agents', link: '/agents/' },
            { label: 'Glossary', link: '/glossary/' },
            { label: 'Changelog', link: '/changelog/' },
          ],
        },
      ],
      customCss: ['./src/styles/custom.css'],
      components: {
        ThemeSelect: './src/components/ThemeToggle.astro',
      },
    }),
  ],
});
