// @ts-check
import { defineConfig } from 'astro/config';
import starlight from '@astrojs/starlight';

// https://astro.build/config
export default defineConfig({
	integrations: [
		starlight({
			title: 'terraform-proxmox-talos-cluster',
			social: {
				github: 'https://github.com/pascalinthecloud/terraform-proxmox-talos-cluster',
			},
			sidebar: [
				{
					label: 'Guides',
					items: [
						// Each item here is one entry in the navigation menu.
						{ label: 'Setup talos cluster', slug: 'guides/setup' },
						{ label: 'Upgrade talos', slug: 'guides/upgrade_talos' },
					],
				},
				{
					label: 'Reference',
					autogenerate: { directory: 'reference' },
				},
			],
		}),
	],
});
