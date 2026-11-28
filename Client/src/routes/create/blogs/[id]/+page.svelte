<script lang="ts">
    import { CreateNav } from "#lib/ui/nav";
    import { Popup, MarkdownHelp, Dropdown } from "#lib/ui/misc";
    import { IconDeviceFloppy, IconHelp, IconBookUpload, IconPencilStar, IconCalendarWeek } from "@tabler/icons-svelte";
    import { CrEditor } from "#lib/ui/forms";
	import { enhance } from "$app/forms";
    import type { PageProps } from "./$types";

    let { data }: PageProps = $props();
    let showMarkdownHints = $state(false);
    let metadata = $state({
        // svelte-ignore state_referenced_locally
        visibility: data.blog.visibility,
        // svelte-ignore state_referenced_locally
        license: data.blog.license,
    });
</script>

<form method="POST" use:enhance={({ formData }) => {
    formData.set('visibility', metadata.visibility);
    formData.set('license', metadata.license);
}}>
    <CreateNav
        showNav={false}
        returnURL="/create/blogs"
    >
        {#snippet leftTools()}
            <fieldset 
                aria-label="Visibility"
                class="flex items-center bg-cr-select rounded-lg overflow-hidden opacity-50 transition-opacity not-disabled:opacity-100" 
                disabled={!data.blog.publishedOn}
            >
                <button 
                    type="button" 
                    class="text-sm all-small-caps font-semibold tracking-wide p-2 cursor-pointer disabled:cursor-not-allowed"
                    class:bg-cr-header={metadata.visibility === 'Public'}
                    class:text-white={metadata.visibility === 'Public'}
                    onclick={() => metadata.visibility = 'Public'}
                    disabled={!data.blog.publishedOn}
                >
                    Public
                </button>
                <button 
                    type="button" 
                    class="text-sm all-small-caps font-semibold tracking-wide p-2 cursor-pointer disabled:cursor-not-allowed"
                    class:bg-cr-header={metadata.visibility === 'Profile'}
                    class:text-white={metadata.visibility === 'Profile'}
                    onclick={() => metadata.visibility = 'Profile'}
                    disabled={!data.blog.publishedOn}
                >
                    Profile
                </button>
                <button 
                    type="button" 
                    class="text-sm all-small-caps font-semibold tracking-wide p-2 cursor-pointer disabled:cursor-not-allowed"
                    class:bg-cr-header={metadata.visibility === 'Private'}
                    class:text-white={metadata.visibility === 'Private'}
                    onclick={() => metadata.visibility = 'Private'}
                    disabled={!data.blog.publishedOn}
                >
                    Private
                </button>
            </fieldset>
        {/snippet}
        {#snippet header()}
            <h3 class="flex items-center text-xl font-bold tracking-tighter text-cr-header! relative top-0.5">Editing "{data.blog.title}"</h3>
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
            <button class="cr-button" type="submit">
                <span class="button-icon"><IconDeviceFloppy size="1.125rem" /></span>
                <span class="button-text">Save</span>
            </button>
            <span class="mx-1"></span>
            <Dropdown kind="create" primary={true} offset="0.75rem" ariaLabel="Publish Blog">
                {#snippet trigger()}
                    <span class="button-icon"><IconBookUpload size="1.125rem" /></span>
                    <span class="button-text">Publish</span>
                {/snippet}
                {#snippet content()}
                    <button class="dropdown-btn cr" type="button">
                        <span class="mr-2"><IconPencilStar size="1.25rem" /></span>
                        <span>Publish Now</span>
                    </button>
                    <button class="dropdown-btn cr" type="button">
                        <span class="mr-2"><IconCalendarWeek size="1.25rem" /></span>
                        <span>Schedule Post</span>
                    </button>
                {/snippet}
            </Dropdown>
            <!--<button class="cr-button primary" type="button">
                <span class="button-icon"><IconBookUpload size="1.125rem" /></span>
                <span class="button-text">Publish</span>
            </button>-->
        {/snippet}
    </CreateNav>
    <div class="flex flex-col w-full max-w-7xl min-h-[calc(100dvh-56px)] h-auto justify-start pt-12 pb-8 mx-auto">
        <textarea
            id="title"
            name="title"
            placeholder="A Day in the Life"
            maxlength="48"
            class="resize-none field-sizing-content box-border w-full text-center content-center h-24 text-5xl font-header text-cr-header placeholder:text-cr-placeholder placeholder:relative placeholder:top-0.5 border-0 bg-transparent focus:ring-0 focus:border-0"
            value={data.blog.title}
        ></textarea>
        <CrEditor
            name="body"
            placeholder="On a cool summer's day, in the lonesome quiet beneath the willow..."
            value={data.blog.body}
            defaultPreview={true}
        />
    </div>
</form>
