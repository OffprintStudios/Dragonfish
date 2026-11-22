import { error, fail, redirect } from "@sveltejs/kit";
import type { Actions, PageServerLoad } from "./$types";
import { BASE_URL } from "#lib/http";
import type { Profile } from "#lib/models/accounts";
import { DEFAULT_EXPIRATION, PROFILE_ID_KEY, SESSION_TOKEN_KEY } from "#lib/util/constants.ts";

export const load: PageServerLoad = async ({ cookies }) => {
    const token = cookies.get(SESSION_TOKEN_KEY);

    if (!token) {
        error(401, "Unauthorized");
    }

    const apiResponse = await fetch(`${BASE_URL}/accounts/profiles/all`, {
        method: "GET",
        headers: {
            "Authorization": `Bearer ${token}`,
        },
    });

    if (apiResponse.ok) return { profiles: (await apiResponse.json()) as Profile[] };
    throw error(apiResponse.status, apiResponse.statusText);
}

export const actions = {
    select: async ({ request, cookies, fetch }) => {
        const data = await request.formData();
        const profileID = data.get('profileID')?.toString();

        const apiResponse = await fetch(`${BASE_URL}/accounts/profiles/${profileID}/verify`, {
            method: 'GET',
            headers: {
                "Authorization": `Bearer ${cookies.get(SESSION_TOKEN_KEY)}`,
            }
        });
        
        if (apiResponse.ok) {
            cookies.delete(PROFILE_ID_KEY, { path: "/" });
            cookies.set(PROFILE_ID_KEY, profileID!, {
                path: "/",
                httpOnly: true,
                secure: process.env.NODE_ENV === 'production',
                sameSite: 'strict',
                maxAge: DEFAULT_EXPIRATION,
            });
            return redirect(303, "/");
        } else {
            const apiError = await apiResponse.json();
            return fail(apiResponse.status, { message: apiError.reason });
        }
    }
} satisfies Actions;