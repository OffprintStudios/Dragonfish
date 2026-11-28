import { BASE_URL } from '#lib/http';
import type { BlogCreate } from '#lib/models/blogs';
import { PROFILE_ID_KEY, SESSION_TOKEN_KEY } from '#lib/util/constants.ts';
import type { Actions } from './$types';
import { fail, redirect } from '@sveltejs/kit';

export const actions = {
    default: async ({ request, fetch, cookies }) => {
        const data = await request.formData();
        const title = data.get("title");
        const body = data.get("body");

        if (!title || (title!.toString().trim().length < 3 || title!.toString().trim().length > 48)) {
            return fail(400, { message: "Titles need to be between 3 and 48 characters long." });
        }

        if (!body || body!.toString().trim().length < 3) {
            return fail(400, { message: "Blogs should contain at least three characters." });
        }

        const form: BlogCreate = { title: title.toString(), body: body.toString() };
        const apiResponse = await fetch(`${BASE_URL}/profiles/${cookies.get(PROFILE_ID_KEY)}/blogs/new`, {
            method: 'POST',
            body: JSON.stringify(form),
            headers: {
                "Authorization": `Bearer ${cookies.get(SESSION_TOKEN_KEY)}`,
                "Content-Type": "application/json",
            },
        });

        if (apiResponse.ok) {
            return redirect(303, "/create/blogs");
        }
        
        const error = await apiResponse.json();
        return fail(apiResponse.status, { message: error.reason });
    }
} satisfies Actions;