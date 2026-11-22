<script lang="ts">
    import { AuthState } from "#lib/state/auth.svelte";
    import type { PageProps } from "./$types";
    import { LinkBlock } from "#lib/ui/misc";
    import { IconNewSection, IconSearch } from "@tabler/icons-svelte";

    let auth = AuthState.useState();
    let { data }: PageProps = $props();
</script>

<div
    class="hidden md:flex items-center justify-center w-full p-2 bg-zinc-200/50 dark:bg-zinc-700/50 backdrop-blur-lg md:rounded-b-xl border-b border-t-0 md:border-t border-x-0 md:border-x border-zinc-600/25 dark:border-zinc-300/25 transition"
    style="box-shadow: var(--dropshadow)"
>
    {#if data.profile!.id === auth.currProfile?.id}
        <LinkBlock
            id="add-new"
            title="Add New Blog"
            href="/create/blogs/new"
            primary
        >
            <span class="button-icon"><IconNewSection size="1.125rem" /></span>
            <span class="button-text">Add</span>
        </LinkBlock>
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