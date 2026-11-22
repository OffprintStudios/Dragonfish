<script lang="ts">
    import type { PageServerLoad } from "./$types";
    import { CreateNav } from "#lib/ui/nav";

    let { data }: PageServerLoad = $props();
</script>

<CreateNav>
    {#snippet header()}
        <span class="hidden">Overview</span>
    {/snippet}
    {#snippet tools()}
        <span class="hidden">Overview Tools</span>
    {/snippet}
</CreateNav>