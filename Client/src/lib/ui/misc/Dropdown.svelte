<script lang="ts">
	import type { Snippet } from 'svelte';

	interface Props {
		trigger: Snippet;
		content: Snippet;
        kind?: 'generic' | 'create';
        primary?: boolean;
		align?: 'left' | 'right';
        offset?: string;
		ariaLabel?: string;
	}

	let {
		trigger,
		content,
        kind = 'generic',
        primary = false,
		align = 'left',
        offset = '0.375rem',
		ariaLabel = 'Toggle menu'
	}: Props = $props();

	const uid = $props.id();
	const popoverId = `popover-${uid}`;
	const anchorName = `--anchor-${uid}`;

    let isOpen = $state(false);
    function handleToggle(event: ToggleEvent) {
		isOpen = event.newState === 'open';
	}
</script>

<div class="inline-block">
	<button
		type="button"
		class:btn={kind === 'generic'}
        class:cr-button={kind === 'create'}
        class:primary={primary}
        class:active={isOpen}
		popovertarget={popoverId}
		aria-label={ariaLabel}
		style:anchor-name={anchorName}
	>
		{@render trigger()}
	</button>

	<div
		id={popoverId}
		popover="auto"
		role="menu"
        ontoggle={handleToggle}
        class="dropdown-menu fixed inset-auto m-0 min-w-62 rounded-lg border p-1 shadow-lg"
        class:border-slate-200={kind === 'generic'}
        class:bg-white={kind === 'generic'}
        class:bg-cr-background={kind === 'create'}
        class:border-cr-header={kind === 'create'}
        class:align-right={align === 'right'}
        class:align-left={align === 'left'}
		style:position-anchor={anchorName}
        style:--dropdown-offset={offset}
	>
		{@render content()}
	</div>
</div>

<style>
	.dropdown-menu {
        --dropdown-offset: 0.375rem;

		top: calc(anchor(bottom) + var(--dropdown-offset));
		position-try-fallbacks: flip-block, flip-inline;

		opacity: 0;
		transform: translateY(-4px) scale(0.98);
		transition:
			opacity 0.15s ease,
			transform 0.15s ease,
			display 0.15s allow-discrete,
			overlay 0.15s allow-discrete;
	}

	.dropdown-menu.align-left {
		left: anchor(left);
	}

	.dropdown-menu.align-right {
		right: anchor(right);
	}

	.dropdown-menu:popover-open {
		opacity: 1;
		transform: translateY(0) scale(1);
	}

	@starting-style {
		.dropdown-menu:popover-open {
			opacity: 0;
			transform: translateY(-4px) scale(0.98);
		}
	}

	.dropdown-menu :global(> :not(hr)) {
		display: flex;
		align-items: center;
		width: 100%;
		padding: 0.5rem 0.75rem;
		border: 0;
		border-radius: 0.375rem;
		background: transparent;
		color: #1e293b;
		font-size: 0.875rem;
		line-height: 1.25rem;
		text-align: left;
		text-decoration: none;
		cursor: pointer;
		box-sizing: border-box;
	}

	.dropdown-menu :global(> :not(hr):hover),
	.dropdown-menu :global(> :not(hr):focus-visible) {
		background-color: #f1f5f9;
		outline: none;
	}
</style>