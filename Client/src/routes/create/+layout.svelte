<script lang="ts">
    import type { LayoutProps } from "./$types";

    let { children }: LayoutProps = $props();
</script>

<div class="paper relative w-full min-h-dvh bg-cr-background text-cr-text">
    {@render children()}
</div>
