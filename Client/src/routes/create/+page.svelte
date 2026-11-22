<script lang="ts">
    import { CreateNav } from "#lib/ui/nav";
</script>

<CreateNav>
    {#snippet header()}
        <span class="hidden">Overview</span>
    {/snippet}
    {#snippet tools()}
        <span class="hidden">Overview Tools</span>
    {/snippet}
</CreateNav>

<div class="empty h-dvh flex flex-col items-center justify-center relative -top-24">
    <h3 class="text-cr-header!">Nothing to see here...</h3>
    <p>This page is still under construction. Check back later!</p>
</div>