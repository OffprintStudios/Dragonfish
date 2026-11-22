<script lang="ts">
    import { AuthState } from "#lib/state/auth.svelte";
    import type { PageProps } from "./$types";
    import { LinkBlock, Button } from "#lib/ui/misc";
    import { IconNewSection, IconCards, IconListDetails, IconSearch } from "@tabler/icons-svelte";

    let auth = AuthState.useState();
    let { data }: PageProps = $props();
    let cardView = $state(true);
</script>

<div
    class="hidden md:flex items-center justify-center w-full p-2 bg-zinc-200/50 dark:bg-zinc-700/50 backdrop-blur-lg md:rounded-b-xl border-b border-t-0 md:border-t border-x-0 md:border-x border-zinc-600/25 dark:border-zinc-300/25 transition"
    style="box-shadow: var(--dropshadow)"
>
    {#if data.profile!.id === auth.currProfile?.id}
        <LinkBlock
            id="add-new"
            title="Add New Blog"
            href="/create/blogs"
            primary
        >
            <span class="button-icon"><IconNewSection size="1.125rem" /></span>
            <span class="button-text">Add</span>
        </LinkBlock>
        <span class="mx-2 relative -top-0.5 text-4xl font-extralight text-zinc-300 dark:text-zinc-600">|</span>
        <Button
            id="card-view"
            title="Card View"
            onclick={() => cardView = true}
            active={cardView}
        >
            <span class="button-icon no-text py-[0.075rem]!"><IconCards size="1.125rem" /></span>
        </Button>
        <span class="mx-0.5"></span>
        <Button
            id="list-view"
            title="List View"
            onclick={() => cardView = false}
            active={!cardView}
        >
            <span class="button-icon no-text py-[0.075rem]!"><IconListDetails size="1.125rem" /></span>
        </Button>
    {/if}
    <div class="flex-1"></div>
    <form class="flex items-center bg-zinc-300 dark:bg-zinc-600 rounded-xl overflow-hidden relative h-9.5">
        <input type="text" placeholder="Search..." class="bg-transparent border-0 focus:border-0 ring-0" />
        <button title="Search" class="px-4 py-3 hover:bg-zinc-400 dark:hover:bg-zinc-500"><IconSearch size="1rem" /></button>
    </form>
</div>

<div>
    {#if data.blogs.items.length === 0}
        <div class="empty">
            <h3>Nothing to see here...</h3>
            {#if auth.currProfile?.id === data.profile.id}
                <p>Hit the Add button up there to get started!</p>
            {:else}
                <p>Come back later to find out if {data.profile.username}'s posted something!</p>
            {/if}
        </div>
    {:else}
        Has Blogs: {data.blogs.items.length}
    {/if}
</div>