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