<script lang="ts">
    import { CreateNav } from "#lib/ui/nav";
    import { Popup, MarkdownHelp } from "#lib/ui/misc";
    import { IconDeviceFloppy, IconHelp } from "@tabler/icons-svelte";
    import { CrEditor } from "#lib/ui/forms";
	import { enhance } from "$app/forms";

    let showMarkdownHints = $state(false);
</script>

<form method="POST" use:enhance>
    <CreateNav
        showNav={false}
        returnURL="/create/blogs"
    >
        {#snippet header()}
            <h3 class="flex items-center text-xl font-bold tracking-tighter text-cr-header! relative top-0.5">Add a New Blog</h3>
        {/snippet}
        {#snippet tools()}
            <button
                type="button"
                class="flex items-center text-cr-header p-2 transition rounded-lg hover:bg-cr-hover cursor-pointer"
                onclick={() => showMarkdownHints = true}
            >
                <span><IconHelp size="1.25rem" /></span>
            </button>
            <Popup
                id="markdown-hints"
                bind:show={showMarkdownHints}
            >
                <MarkdownHelp />
            </Popup>
            <span class="mx-1"></span>
            <button class="cr-button primary" type="submit">
                <span class="button-icon"><IconDeviceFloppy size="1.125rem" /></span>
                <span class="button-text">Save</span>
            </button>
        {/snippet}
    </CreateNav>
    <div class="flex flex-col w-full max-w-7xl min-h-[calc(100dvh-56px)] h-auto justify-start pt-12 pb-8 mx-auto">
        <textarea
            id="title"
            name="title"
            placeholder="A Day in the Life"
            maxlength="48"
            class="resize-none field-sizing-content box-border w-full text-center content-center h-24 text-5xl font-header text-cr-header placeholder:text-cr-placeholder placeholder:relative placeholder:top-0.5 border-0 bg-transparent focus:ring-0 focus:border-0"
        ></textarea>
        <CrEditor
            name="body"
            placeholder="On a cool summer's day, in the lonesome quiet beneath the willow..."
        />
    </div>
</form>
