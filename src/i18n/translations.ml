type translations =
  { login_placeholder_email: string
  ; login_placeholder_password: string
  ; login_sign_in: string
  ; login_title: string
  ; login_label_email: string
  ; login_label_password: string
  ; login_remember_me: string
  ; login_footer: string
  ; sidebar_app_name: string
  ; tabbar_copy: string
  ; tabbar_confirm_skeleton: string
  ; tabbar_skeleton: string
  ; codebar_all_changes_saved: string
  ; codebar_saving: string
  ; spinner_modal_processing: string
  ; spinner_modal_ready: string
  ; codebar_local_run: string
  ; codebar_evaluate: string
  ; codebar_confirm_save: string
  ; codebar_evaluate_save: string
  ; codebar_run: string
  ; codebar_confirm_run: string
  ; modal_cancel: string
  ; modal_confirm: string
  ; modal_confirm_action: string
  ; submission_sending: string
  ; submission_processing: string
  ; submission_result: string
  ; submission_close: string
  ; problem_time_limit: string
  ; problem_memory_limit: string
  ; problem_description: string
  ; problem_input: string
  ; problem_output: string
  ; problem_not_found: string
  ; problem_submit_solution: string
  ; problem_submit_btn: string
  ; subform_placeholder_source: string
  ; subform_label_language: string
  ; subform_label_source: string
  ; subform_submit: string
  ; submissions_col_id: string
  ; submissions_col_problem: string
  ; submissions_col_language: string
  ; submissions_col_result: string
  ; submissions_col_time: string
  ; submissions_recent_title: string
  ; contests_title: string
  ; problems_col_id: string
  ; problems_col_name: string
  ; problems_title: string
  ; settings_title: string
  ; settings_theme_label: string
  ; settings_theme_desc: string
  ; settings_font_size_label: string
  ; settings_font_size_desc: string
  ; settings_tab_size_label: string
  ; settings_tab_size_desc: string
  ; settings_wrap_lines: string
  ; settings_auto_save: string
  ; settings_save_btn: string
  ; settings_reset_btn: string
  ; settings_language_label: string
  ; config_editor_title: string
  ; config_history_title: string
  ; config_col_version: string
  ; config_col_timestamp: string
  ; config_col_changed_by: string
  ; config_col_action: string
  ; config_col_langs: string
  ; config_loading_history: string
  ; settings_appearance_title: string
  ; settings_editor_title: string
  ; settings_behavior_title: string
  ; settings_tab_general: string
  ; settings_tab_yodac: string
  ; settings_tab_users: string
  ; settings_tab_stats: string
  ; settings_tab_problems: string
  ; settings_line_wrap_label: string
  ; settings_auto_save_label: string
  ; settings_admin_badge: string
  ; settings_judge_badge: string
  ; config_meta_version: string
  ; config_meta_updated: string
  ; config_meta_by: string
  ; config_total_entries: string
  ; config_no_history: string
  ; config_save_no_changes: string
  ; config_edit_btn: string
  ; config_cancel_edit_btn: string
  ; progress_status_label: string
  ; progress_time_left_label: string
  ; progress_progress_label: string
  ; progress_title: string
  ; test_type_text: string
  ; test_type_json: string
  ; test_invalid_json: string
  ; dropdown_select_problem: string
  ; sidebar_dashboard: string
  ; sidebar_codeboard: string
  ; sidebar_submissions: string
  ; sidebar_switch_contest: string
  ; sidebar_settings: string
  ; sidebar_sign_out: string
  ; login_sign_out: string
  ; users_manage_title: string
  ; users_manage_subtitle: string
  ; users_loading: string
  ; users_refresh_btn: string
  ; users_create_title: string
  ; users_create_username_placeholder: string
  ; users_create_password: string
  ; users_create_password_placeholder: string
  ; users_groups_placeholder: string
  ; users_create_submit: string
  ; users_col_id: string
  ; users_col_username: string
  ; users_col_role: string
  ; users_col_groups: string
  ; users_col_created_at: string
  ; users_col_last_seen_at: string
  ; users_col_actions: string
  ; users_select_all: string
  ; users_delete_selected_btn: string
  ; users_delete_confirm: string
  ; users_delete_failed: string
  ; users_notice_deleted: string
  ; users_action_edit: string
  ; users_action_save: string
  ; users_action_cancel: string
  ; users_notice_created: string
  ; users_notice_updated: string
  ; users_validation_required: string
  ; users_import_in_progress: string
  ; users_import_summary: string
  ; users_import_invalid_header: string
  ; users_import_invalid_row: string
  ; users_import_invalid_role: string
  ; users_import_read_failed: string
  ; users_import_input_missing: string
  ; users_import_empty_file: string
  ; users_import_btn: string
  ; stats_loading: string
  ; stats_empty: string
  ; stats_refresh_btn: string
  ; stats_error_prefix: string
  ; stats_parse_error: string
  ; stats_service_info: string
  ; stats_yodab: string
  ; stats_yodac: string
  ; stats_api_version: string
  ; stats_yoda_version: string
  ; stats_contributors: string
  ; stats_requests_total: string
  ; stats_requests_per_minute: string
  ; stats_submissions_total: string
  ; stats_submissions_per_minute: string
  ; stats_queued_jobs_total: string
  ; stats_queued_jobs_per_minute: string
  ; stats_processed_jobs_total: string
  ; stats_processed_jobs_per_minute: string
  ; spinner_model_close: string
  ; problems_manage_title: string
  ; problems_manage_subtitle: string
  ; problems_loading: string
  ; problems_search_placeholder: string
  ; problems_select_contest: string
  ; problems_no_contest: string
  ; problems_add_btn: string
  ; problems_add_title: string
  ; problems_edit_title: string
  ; problems_code_label: string
  ; problems_title_label: string
  ; problems_difficulty_label: string
  ; problems_time_limit_label: string
  ; problems_memory_limit_label: string
  ; problems_description_label: string
  ; problems_input_spec_label: string
  ; problems_output_spec_label: string
  ; problems_cancel_btn: string
  ; problems_submit_btn: string
  ; problems_save_changes: string
  ; problems_delete_confirm: string
  ; problems_testcases_title: string
  ; problems_add_testcase: string
  ; problems_test_input_label: string
  ; problems_test_output_label: string
  ; problems_is_sample_label: string
  ; problems_edit_testcase: string
  ; problems_delete_testcase: string
  ; problems_easy: string
  ; problems_medium: string
  ; problems_hard: string
  ; problems_error_load: string
  ; problems_error_save: string
  ; problems_error_delete: string
  ; problems_success_created: string
  ; problems_success_updated: string
  ; problems_success_deleted: string
  ; problems_confirm_delete: string }

let en =
  { login_placeholder_email= "name@example.com"
  ; login_placeholder_password= "Password"
  ; login_sign_in= "Sign in"
  ; login_title= "Please sign in"
  ; login_label_email= "Email address"
  ; login_label_password= "Password"
  ; login_remember_me= "Remember me"
  ; login_footer= "© The Yoda Team 2026"
  ; sidebar_app_name= "YodaApp"
  ; tabbar_copy= "Copy"
  ; tabbar_confirm_skeleton=
      "Do you want to replace the skeleton? All unsaved changes will be \
       lost."
  ; tabbar_skeleton= "Skeleton"
  ; codebar_all_changes_saved= "All changes saved"
  ; codebar_saving= "Saving..."
  ; spinner_modal_processing= "Processing..."
  ; spinner_modal_ready= "Ready to start operation."
  ; codebar_local_run= "Local Run"
  ; codebar_evaluate= "Evaluate"
  ; codebar_confirm_save=
      "Do you want to evaluate and permanently save your work for '%s' ? \
       This action cannot be undone and will cound towards your submission \
       limit."
  ; codebar_evaluate_save= "Evaluate and save all your work"
  ; modal_confirm_action= "Confirm action"
  ; submission_sending= "Sending your solution..."
  ; submission_processing= "Processing your solution... (polling every 2s)"
  ; submission_result= "Result:"
  ; submission_close= "Close"
  ; codebar_run= "Run the code"
  ; codebar_confirm_run= "Do you want to run the '%s' code ?"
  ; modal_cancel= "Cancel"
  ; modal_confirm= "Confirm"
  ; problem_submit_solution= "Submit your solution below."
  ; problem_time_limit= "Time limit"
  ; problem_memory_limit= "Memory limit"
  ; problem_description= "Description"
  ; problem_input= "Input"
  ; problem_output= "Output"
  ; problem_not_found= "Problem not found"
  ; problem_submit_btn= "Submit"
  ; subform_placeholder_source= "Source code"
  ; subform_label_language= "Language:"
  ; subform_label_source= "Source code:"
  ; subform_submit= "Submit"
  ; submissions_col_id= "#"
  ; submissions_col_problem= "Problem"
  ; submissions_col_language= "Language"
  ; submissions_col_result= "Result"
  ; submissions_col_time= "Time"
  ; submissions_recent_title= "Recent Submissions"
  ; contests_title= "Contests"
  ; problems_col_id= "ID"
  ; problems_col_name= "Problem"
  ; problems_title= "Problems"
  ; settings_title= "Settings"
  ; settings_theme_label= "Theme"
  ; settings_theme_desc= "Choose the editor color theme."
  ; settings_font_size_label= "Font Size"
  ; settings_font_size_desc= "Adjust the editor font size."
  ; settings_tab_size_label= "Tab Size"
  ; settings_tab_size_desc= "Number of spaces per tab indentation."
  ; settings_wrap_lines= "Wrap long lines in the editor."
  ; settings_auto_save= "Automatically save your code while typing."
  ; settings_save_btn= "Save"
  ; settings_reset_btn= "Reset"
  ; settings_language_label= "Language"
  ; config_editor_title= "Config Editor"
  ; config_history_title= "Configuration History"
  ; config_col_version= "Version"
  ; config_col_timestamp= "Timestamp"
  ; config_col_changed_by= "Changed By"
  ; config_col_action= "Action"
  ; config_col_langs= "Langs"
  ; config_loading_history= "Loading history..."
  ; settings_appearance_title= "Appearance"
  ; settings_editor_title= "Editor"
  ; settings_behavior_title= "Behavior"
  ; settings_tab_general= "General"
  ; settings_tab_yodac= "YodaC"
  ; settings_tab_users= "Users"
  ; settings_tab_stats= "Stats"
  ; settings_line_wrap_label= "Line Wrapping"
  ; settings_auto_save_label= "Auto-save"
  ; settings_admin_badge= "Admin Access"
  ; settings_judge_badge= "Judge Access"
  ; settings_tab_problems= "Problems"
  ; config_meta_version= "Version: %s"
  ; config_meta_updated= "Updated: %s"
  ; config_meta_by= "By: %s"
  ; config_total_entries= "Total entries: %s"
  ; config_no_history= "No history"
  ; config_save_no_changes= "No changes to save."
  ; config_edit_btn= "Edit"
  ; config_cancel_edit_btn= "Cancel Edit"
  ; progress_status_label= "Status: "
  ; progress_time_left_label= "Time Left: "
  ; progress_progress_label= "Progress"
  ; progress_title= "Contest Progress"
  ; test_type_text= "Text"
  ; test_type_json= "JSON"
  ; test_invalid_json= "Invalid JSON"
  ; dropdown_select_problem= "-- Select a problem --"
  ; sidebar_dashboard= "Dashboard"
  ; sidebar_codeboard= "Codeboard"
  ; sidebar_submissions= "Submissions"
  ; sidebar_switch_contest= "Switch Contest"
  ; sidebar_settings= "Settings"
  ; sidebar_sign_out= "Sign out"
  ; login_sign_out= "Sign out"
  ; users_manage_title= "User management"
  ; users_manage_subtitle=
      "Create accounts and update roles directly from this table."
  ; users_loading= "Loading users..."
  ; users_refresh_btn= "Refresh"
  ; users_create_title= "Add a new user"
  ; users_create_username_placeholder= "Username"
  ; users_create_password= "Password"
  ; users_create_password_placeholder= "Temporary password"
  ; users_groups_placeholder= "group-a, group-b"
  ; users_create_submit= "Create user"
  ; users_col_id= "ID"
  ; users_col_username= "Username"
  ; users_col_role= "Role"
  ; users_col_groups= "Groups"
  ; users_col_created_at= "Created"
  ; users_col_last_seen_at= "Last Seen"
  ; users_col_actions= "Actions"
  ; users_select_all= "Select all"
  ; users_delete_selected_btn= "Delete selected (%s)"
  ; users_delete_confirm= "Delete %s selected users?"
  ; users_delete_failed= "Failed to delete %s selected users."
  ; users_notice_deleted= "Selected users deleted successfully."
  ; users_action_edit= "Edit"
  ; users_action_save= "Save"
  ; users_action_cancel= "Cancel"
  ; users_notice_created= "User created successfully."
  ; users_notice_updated= "User updated successfully."
  ; users_validation_required=
      "Username and password are required for new users."
  ; users_import_in_progress= "Importing users..."
  ; users_import_summary= "Import completed: %s users created, %s errors."
  ; users_import_invalid_header=
      "Invalid CSV header. Expected: username,password,role,groups"
  ; users_import_invalid_row= "Invalid CSV row at line"
  ; users_import_invalid_role= "Invalid role at line"
  ; users_import_read_failed= "Failed to read the selected CSV file."
  ; users_import_input_missing=
      "Import file input is unavailable on this page."
  ; users_import_empty_file= "The selected CSV file is empty."
  ; users_import_btn= "Import users"
  ; stats_loading= "Loading stats..."
  ; stats_empty= "No stats available."
  ; stats_refresh_btn= "Refresh"
  ; stats_error_prefix= "Failed to load stats (HTTP %s)"
  ; stats_parse_error= "Failed to parse stats: %s"
  ; stats_service_info= "Service Info"
  ; stats_yodab= "YodaB Metrics"
  ; stats_yodac= "YodaC Metrics"
  ; stats_api_version= "API Version"
  ; stats_yoda_version= "Yoda Version"
  ; stats_contributors= "Contributors"
  ; stats_requests_total= "Requests Total"
  ; stats_requests_per_minute= "Requests per Minute"
  ; stats_submissions_total= "Submissions Total"
  ; stats_submissions_per_minute= "Submissions per Minute"
  ; stats_queued_jobs_total= "Queued Jobs"
  ; stats_queued_jobs_per_minute= "Queued Jobs per Minute"
  ; stats_processed_jobs_total= "Processed Jobs Total"
  ; stats_processed_jobs_per_minute= "Processed Jobs per Minute"
  ; spinner_model_close= "Start"
  ; problems_manage_title= "Problem Management"
  ; problems_manage_subtitle= "Add, edit, or remove problems and test cases."
  ; problems_loading= "Loading problems..."
  ; problems_search_placeholder= "Search problems..."
  ; problems_select_contest= "Select Contest"
  ; problems_no_contest= "No contest selected"
  ; problems_add_btn= "Add Problem"
  ; problems_add_title= "Add New Problem"
  ; problems_edit_title= "Edit Problem"
  ; problems_code_label= "Code (slug: id-problem-name)"
  ; problems_title_label= "Title"
  ; problems_difficulty_label= "Difficulty"
  ; problems_time_limit_label= "Time Limit (ms)"
  ; problems_memory_limit_label= "Memory Limit (MB)"
  ; problems_description_label= "Description"
  ; problems_input_spec_label= "Input Specification"
  ; problems_output_spec_label= "Output Specification"
  ; problems_cancel_btn= "Cancel"
  ; problems_submit_btn= "Submit"
  ; problems_save_changes= "Save Changes"
  ; problems_delete_confirm= "Delete this problem?"
  ; problems_testcases_title= "Test Cases"
  ; problems_add_testcase= "Add Test Case"
  ; problems_test_input_label= "Input"
  ; problems_test_output_label= "Output"
  ; problems_is_sample_label= "Sample"
  ; problems_edit_testcase= "Edit Test Case"
  ; problems_delete_testcase= "Delete Test Case?"
  ; problems_easy= "Easy"
  ; problems_medium= "Medium"
  ; problems_hard= "Hard"
  ; problems_error_load= "Failed to load problems: %s"
  ; problems_error_save= "Failed to save problem: %s"
  ; problems_error_delete= "Failed to delete problem."
  ; problems_success_created= "Problem created."
  ; problems_success_updated= "Problem updated."
  ; problems_success_deleted= "Problem deleted."
  ; problems_confirm_delete= "Confirm Delete" }

let fr =
  { login_placeholder_email= "nom@exemple.com"
  ; login_placeholder_password= "Mot de passe"
  ; login_sign_in= "Se connecter"
  ; login_title= "Veuillez vous connecter"
  ; login_label_email= "Adresse e-mail"
  ; login_label_password= "Mot de passe"
  ; login_remember_me= "Se souvenir de moi"
  ; login_footer= "© L'équipe Yoda 2026"
  ; sidebar_app_name= "YodaApp"
  ; tabbar_copy= "Copier"
  ; tabbar_confirm_skeleton=
      "Voulez-vous remplacer le squelette ? Toutes les modifications non \
       enregistrées seront perdues."
  ; tabbar_skeleton= "Squelette"
  ; codebar_all_changes_saved= "Toutes les modifications enregistrées"
  ; codebar_saving= "Enregistrement en cours..."
  ; spinner_modal_processing= "Traitement en cours..."
  ; spinner_modal_ready= "Prêt à démarrer."
  ; codebar_local_run= "Exécution locale"
  ; codebar_evaluate= "Évaluer"
  ; codebar_confirm_save=
      "Voulez-vous évaluer et sauvegarder définitivement votre travail pour \
       '%s' ? Cette action est irréversible et comptera dans votre limite \
       de soumissions."
  ; codebar_evaluate_save= "Évaluer et sauvegarder tout votre travail"
  ; modal_confirm_action= "Confirmer l'action"
  ; submission_sending= "Envoi de votre solution..."
  ; submission_processing= "Traitement en cours... (sonde toutes les 2s)"
  ; submission_result= "Résultat :"
  ; submission_close= "Fermer"
  ; codebar_run= "Exécuter le code"
  ; codebar_confirm_run= "Voulez-vous exécuter le code '%s' ?"
  ; modal_cancel= "Annuler"
  ; modal_confirm= "Confirmer"
  ; problem_submit_solution= "Soumettez votre solution ci-dessous."
  ; problem_time_limit= "Limite de temps"
  ; problem_memory_limit= "Limite de mémoire"
  ; problem_description= "Description"
  ; problem_input= "Entrée"
  ; problem_output= "Sortie"
  ; problem_not_found= "Problème non trouvé"
  ; problem_submit_btn= "Soumettre"
  ; subform_placeholder_source= "Code source"
  ; subform_label_language= "Langage :"
  ; subform_label_source= "Code source :"
  ; subform_submit= "Soumettre"
  ; submissions_col_id= "#"
  ; submissions_col_problem= "Problème"
  ; submissions_col_language= "Langage"
  ; submissions_col_result= "Résultat"
  ; submissions_col_time= "Temps"
  ; submissions_recent_title= "Soumissions récentes"
  ; contests_title= "Concours"
  ; problems_col_id= "ID"
  ; problems_col_name= "Problème"
  ; problems_title= "Problèmes"
  ; settings_title= "Paramètres"
  ; settings_theme_label= "Thème"
  ; settings_theme_desc= "Choisissez le thème de couleur de l'éditeur."
  ; settings_font_size_label= "Taille de police"
  ; settings_font_size_desc= "Ajustez la taille de la police de l'éditeur."
  ; settings_tab_size_label= "Taille des tabulations"
  ; settings_tab_size_desc= "Nombre d'espaces par indentation."
  ; settings_wrap_lines= "Activer le retour à la ligne automatique."
  ; settings_auto_save=
      "Sauvegarder automatiquement votre code pendant la frappe."
  ; settings_save_btn= "Enregistrer"
  ; settings_reset_btn= "Réinitialiser"
  ; settings_language_label= "Langue"
  ; config_editor_title= "Éditeur de configuration"
  ; config_history_title= "Historique des configurations"
  ; config_col_version= "Version"
  ; config_col_timestamp= "Horodatage"
  ; config_col_changed_by= "Modifié par"
  ; config_col_action= "Action"
  ; config_col_langs= "Langages"
  ; config_loading_history= "Chargement de l'historique..."
  ; settings_appearance_title= "Apparence"
  ; settings_editor_title= "Éditeur"
  ; settings_behavior_title= "Comportement"
  ; settings_tab_general= "Général"
  ; settings_tab_yodac= "YodaC"
  ; settings_tab_users= "Utilisateurs"
  ; settings_tab_problems= "Problèmes"
  ; settings_line_wrap_label= "Retour à la ligne"
  ; settings_auto_save_label= "Sauvegarde auto."
  ; settings_admin_badge= "Accès Administrateur"
  ; settings_judge_badge= "Accès Juge"
  ; config_meta_version= "Version : %s"
  ; config_meta_updated= "Mis à jour : %s"
  ; config_meta_by= "Par : %s"
  ; config_total_entries= "Total des entrées : %s"
  ; config_no_history= "Aucun historique"
  ; config_save_no_changes= "Aucune modification a enregistrer."
  ; config_edit_btn= "Modifier"
  ; config_cancel_edit_btn= "Annuler"
  ; progress_status_label= "Statut : "
  ; progress_time_left_label= "Temps restant : "
  ; progress_progress_label= "Progression"
  ; progress_title= "Progression du concours"
  ; test_type_text= "Texte"
  ; test_type_json= "JSON"
  ; test_invalid_json= "JSON invalide"
  ; dropdown_select_problem= "-- Sélectionner un problème --"
  ; sidebar_dashboard= "Tableau de bord"
  ; sidebar_codeboard= "Codeboard"
  ; sidebar_submissions= "Soumissions"
  ; sidebar_switch_contest= "Changer de concours"
  ; sidebar_settings= "Parametres"
  ; sidebar_sign_out= "Se deconnecter"
  ; login_sign_out= "Se déconnecter"
  ; users_manage_title= "Gestion des utilisateurs"
  ; users_manage_subtitle=
      "Créez des comptes et modifiez les rôles directement depuis ce \
       tableau."
  ; users_loading= "Chargement des utilisateurs..."
  ; users_refresh_btn= "Actualiser"
  ; users_create_title= "Ajouter un utilisateur"
  ; users_create_username_placeholder= "Nom d'utilisateur"
  ; users_create_password= "Mot de passe"
  ; users_create_password_placeholder= "Mot de passe temporaire"
  ; users_groups_placeholder= "groupe-a, groupe-b"
  ; users_create_submit= "Créer l'utilisateur"
  ; users_col_id= "ID"
  ; users_col_username= "Nom d'utilisateur"
  ; users_col_role= "Rôle"
  ; users_col_groups= "Groupes"
  ; users_col_created_at= "Créé le"
  ; users_col_last_seen_at= "Dernière activité"
  ; users_col_actions= "Actions"
  ; users_select_all= "Tout sélectionner"
  ; users_delete_selected_btn= "Supprimer la sélection (%s)"
  ; users_delete_confirm= "Supprimer %s utilisateurs sélectionnés ?"
  ; users_delete_failed=
      "Impossible de supprimer %s utilisateurs sélectionnés."
  ; users_notice_deleted= "Utilisateurs sélectionnés supprimés avec succès."
  ; users_action_edit= "Modifier"
  ; users_action_save= "Enregistrer"
  ; users_action_cancel= "Annuler"
  ; users_notice_created= "Utilisateur créé avec succès."
  ; users_notice_updated= "Utilisateur mis à jour avec succès."
  ; users_validation_required=
      "Le nom d'utilisateur et le mot de passe sont requis pour créer un \
       utilisateur."
  ; users_import_in_progress= "Importation des utilisateurs..."
  ; users_import_summary=
      "Import terminé : %s utilisateurs créés, %s erreurs."
  ; users_import_invalid_header=
      "En-tête CSV invalide. Attendu : username,password,role,groups"
  ; users_import_invalid_row= "Ligne CSV invalide à la ligne"
  ; users_import_invalid_role= "Rôle invalide à la ligne"
  ; users_import_read_failed=
      "Impossible de lire le fichier CSV sélectionné."
  ; users_import_input_missing=
      "Le champ de fichier d'import n'est pas disponible sur cette page."
  ; users_import_empty_file= "Le fichier CSV sélectionné est vide."
  ; users_import_btn= "Importer les utilisateurs"
  ; settings_tab_stats= "Statistiques"
  ; stats_loading= "Chargement des statistiques..."
  ; stats_empty= "Aucune statistique disponible."
  ; stats_refresh_btn= "Actualiser"
  ; stats_error_prefix= "Impossible de charger les statistiques (HTTP %s)"
  ; stats_parse_error= "Impossible d'analyser les statistiques : %s"
  ; stats_service_info= "Informations du service"
  ; stats_yodab= "Métriques YodaB"
  ; stats_yodac= "Métriques YodaC"
  ; stats_api_version= "Version API"
  ; stats_yoda_version= "Version Yoda"
  ; stats_contributors= "Contributeurs"
  ; stats_requests_total= "Total des requêtes"
  ; stats_requests_per_minute= "Requêtes par minute"
  ; stats_submissions_total= "Total des soumissions"
  ; stats_submissions_per_minute= "Soumissions par minute"
  ; stats_queued_jobs_total= "Taches en file"
  ; stats_queued_jobs_per_minute= "Taches en file par minute"
  ; stats_processed_jobs_total= "Total des taches traitees"
  ; stats_processed_jobs_per_minute= "Taches traitees par minute"
  ; spinner_model_close= "Fermer"
  ; problems_manage_title= "Gestion des problèmes"
  ; problems_manage_subtitle=
      "Ajouter, modifier ou supprimer des problèmes et des cas de test."
  ; problems_loading= "Chargement des problèmes..."
  ; problems_search_placeholder= "Rechercher des problèmes..."
  ; problems_select_contest= "Sélectionner un concours"
  ; problems_no_contest= "Aucun concours sélectionné"
  ; problems_add_btn= "Ajouter un problème"
  ; problems_add_title= "Ajouter un nouveau problème"
  ; problems_edit_title= "Modifier le problème"
  ; problems_code_label= "Code (slug: id-problem-name)"
  ; problems_title_label= "Titre"
  ; problems_difficulty_label= "Difficulté"
  ; problems_time_limit_label= "Limite de temps (ms)"
  ; problems_memory_limit_label= "Limite de mémoire (MB)"
  ; problems_description_label= "Description"
  ; problems_input_spec_label= "Spécification d'entrée"
  ; problems_output_spec_label= "Spécification de sortie"
  ; problems_cancel_btn= "Annuler"
  ; problems_submit_btn= "Soumettre"
  ; problems_save_changes= "Enregistrer les modifications"
  ; problems_delete_confirm= "Supprimer ce problème ?"
  ; problems_testcases_title= "Cas de test"
  ; problems_add_testcase= "Ajouter un cas de test"
  ; problems_test_input_label= "Entrée"
  ; problems_test_output_label= "Sortie"
  ; problems_is_sample_label= "Exemple"
  ; problems_edit_testcase= "Modifier le cas de test"
  ; problems_delete_testcase= "Supprimer le cas de test ?"
  ; problems_easy= "Facile"
  ; problems_medium= "Moyen"
  ; problems_hard= "Difficile"
  ; problems_error_load= "Impossible de charger les problèmes : %s"
  ; problems_error_save= "Impossible d'enregistrer le problème : %s"
  ; problems_error_delete= "Impossible de supprimer le problème."
  ; problems_success_created= "Problème créé."
  ; problems_success_updated= "Problème mis à jour."
  ; problems_success_deleted= "Problème supprimé."
  ; problems_confirm_delete= "Confirmer la suppression" }

let es =
  { login_placeholder_email= "nombre@ejemplo.com"
  ; login_placeholder_password= "Contraseña"
  ; login_sign_in= "Iniciar sesión"
  ; login_title= "Por favor, inicie sesión"
  ; login_label_email= "Dirección de correo"
  ; login_label_password= "Contraseña"
  ; login_remember_me= "Recordarme"
  ; login_footer= "© El equipo Yoda 2026"
  ; sidebar_app_name= "YodaApp"
  ; tabbar_copy= "Copiar"
  ; tabbar_confirm_skeleton=
      "¿Quieres reemplazar el esqueleto? Todas las alteraciones no \
       guardadas serán perdidas."
  ; tabbar_skeleton= "Esqueleto"
  ; codebar_all_changes_saved= "Todos los cambios guardados"
  ; codebar_saving= "Guardando..."
  ; spinner_modal_processing= "Procesando..."
  ; spinner_modal_ready= "Listo para comenzar."
  ; codebar_local_run= "Ejecución local"
  ; codebar_evaluate= "Evaluar"
  ; codebar_confirm_save=
      "¿Quieres evaluar y guardar permanentemente tu trabajo para '%s' ? \
       Esta acción no se puede deshacer y contará hacia tu límite de \
       envíos."
  ; codebar_evaluate_save= "Evaluar y guardar todo tu trabajo"
  ; modal_confirm_action= "Confirmar acción"
  ; submission_sending= "Enviando tu solución..."
  ; submission_processing= "Procesando tu solución... (consultando cada 2s)"
  ; submission_result= "Resultado:"
  ; submission_close= "Cerrar"
  ; codebar_run= "Ejecutar el código"
  ; codebar_confirm_run= "¿Quieres ejecutar el código '%s' ?"
  ; modal_cancel= "Cancelar"
  ; modal_confirm= "Confirmar"
  ; problem_submit_solution= "Envía tu solución abajo."
  ; problem_time_limit= "Límite de tiempo"
  ; problem_memory_limit= "Límite de memoria"
  ; problem_description= "Descripción"
  ; problem_input= "Entrada"
  ; problem_output= "Salida"
  ; problem_not_found= "Problema no encontrado"
  ; problem_submit_btn= "Enviar"
  ; subform_placeholder_source= "Código fuente"
  ; subform_label_language= "Lenguaje:"
  ; subform_label_source= "Código fuente:"
  ; subform_submit= "Enviar"
  ; submissions_col_id= "#"
  ; submissions_col_problem= "Problema"
  ; submissions_col_language= "Lenguaje"
  ; submissions_col_result= "Resultado"
  ; submissions_col_time= "Tiempo"
  ; submissions_recent_title= "Envíos recientes"
  ; contests_title= "Concursos"
  ; problems_col_id= "ID"
  ; problems_col_name= "Problema"
  ; problems_title= "Problemas"
  ; settings_title= "Configuración"
  ; settings_theme_label= "Tema"
  ; settings_theme_desc= "Elige el tema de color del editor."
  ; settings_font_size_label= "Tamaño de fuente"
  ; settings_font_size_desc= "Ajusta el tamaño de la fuente del editor."
  ; settings_tab_size_label= "Tamaño de tabulación"
  ; settings_tab_size_desc= "Número de espacios por indentación."
  ; settings_wrap_lines= "Envolver líneas largas en el editor."
  ; settings_auto_save=
      "Guardar automáticamente tu código mientras escribes."
  ; settings_save_btn= "Guardar"
  ; settings_reset_btn= "Restablecer"
  ; settings_language_label= "Idioma"
  ; config_editor_title= "Editor de configuración"
  ; config_history_title= "Historial de configuración"
  ; config_col_version= "Versión"
  ; config_col_timestamp= "Marca de tiempo"
  ; config_col_changed_by= "Modificado por"
  ; config_col_action= "Acción"
  ; config_col_langs= "Idiomas"
  ; config_loading_history= "Cargando historial..."
  ; settings_appearance_title= "Apariencia"
  ; settings_editor_title= "Editor"
  ; settings_behavior_title= "Comportamiento"
  ; settings_tab_general= "General"
  ; settings_tab_yodac= "YodaC"
  ; settings_tab_users= "Usuarios"
  ; settings_tab_problems= "Problemas"
  ; settings_line_wrap_label= "Envolver líneas"
  ; settings_auto_save_label= "Guardado automático"
  ; settings_admin_badge= "Acceso de Administrador"
  ; settings_judge_badge= "Acceso de Juez"
  ; config_meta_version= "Versión: %s"
  ; config_meta_updated= "Actualizado: %s"
  ; config_meta_by= "Por: %s"
  ; config_total_entries= "Total de entradas: %s"
  ; config_no_history= "Sin historial"
  ; config_save_no_changes= "No hay cambios para guardar."
  ; config_edit_btn= "Editar"
  ; config_cancel_edit_btn= "Cancelar"
  ; progress_status_label= "Estado: "
  ; progress_time_left_label= "Tiempo restante: "
  ; progress_progress_label= "Progreso"
  ; progress_title= "Progreso del concurso"
  ; test_type_text= "Texto"
  ; test_type_json= "JSON"
  ; test_invalid_json= "JSON inválido"
  ; dropdown_select_problem= "-- Seleccionar un problema --"
  ; sidebar_dashboard= "Tablero"
  ; sidebar_codeboard= "Codeboard"
  ; sidebar_submissions= "Envíos"
  ; sidebar_switch_contest= "Cambiar concurso"
  ; sidebar_settings= "Configuración"
  ; sidebar_sign_out= "Cerrar sesion"
  ; login_sign_out= "Cerrar sesión"
  ; users_manage_title= "Gestión de usuarios"
  ; users_manage_subtitle=
      "Crea cuentas y actualiza roles directamente desde esta tabla."
  ; users_loading= "Cargando usuarios..."
  ; users_refresh_btn= "Actualizar"
  ; users_create_title= "Agregar un usuario"
  ; users_create_username_placeholder= "Nombre de usuario"
  ; users_create_password= "Contraseña"
  ; users_create_password_placeholder= "Contraseña temporal"
  ; users_groups_placeholder= "grupo-a, grupo-b"
  ; users_create_submit= "Crear usuario"
  ; users_col_id= "ID"
  ; users_col_username= "Nombre de usuario"
  ; users_col_role= "Rol"
  ; users_col_groups= "Grupos"
  ; users_col_created_at= "Creado"
  ; users_col_last_seen_at= "Última actividad"
  ; users_col_actions= "Acciones"
  ; users_select_all= "Seleccionar todo"
  ; users_delete_selected_btn= "Eliminar seleccionados (%s)"
  ; users_delete_confirm= "¿Eliminar %s usuarios seleccionados?"
  ; users_delete_failed= "No se pudo eliminar %s usuarios seleccionados."
  ; users_notice_deleted= "Usuarios seleccionados eliminados correctamente."
  ; users_action_edit= "Editar"
  ; users_action_save= "Guardar"
  ; users_action_cancel= "Cancelar"
  ; users_notice_created= "Usuario creado correctamente."
  ; users_notice_updated= "Usuario actualizado correctamente."
  ; users_validation_required=
      "El nombre de usuario y la contraseña son obligatorios para crear un \
       usuario."
  ; users_import_in_progress= "Importando usuarios..."
  ; users_import_summary=
      "Importación completada: %s usuarios creados, %s errores."
  ; users_import_invalid_header=
      "Encabezado CSV inválido. Se espera: username,password,role,groups"
  ; users_import_invalid_row= "Fila CSV inválida en la línea"
  ; users_import_invalid_role= "Rol inválido en la línea"
  ; users_import_read_failed= "No se pudo leer el archivo CSV seleccionado."
  ; users_import_input_missing=
      "El campo de archivo para importar no está disponible en esta página."
  ; users_import_empty_file= "El archivo CSV seleccionado está vacío."
  ; users_import_btn= "Importar usuarios"
  ; settings_tab_stats= "Estadisticas"
  ; stats_loading= "Cargando estadisticas..."
  ; stats_empty= "No hay estadisticas disponibles."
  ; stats_refresh_btn= "Actualizar"
  ; stats_error_prefix= "No se pudieron cargar las estadisticas (HTTP %s)"
  ; stats_parse_error= "No se pudieron analizar las estadisticas: %s"
  ; stats_service_info= "Informacion del servicio"
  ; stats_yodab= "Metricas de YodaB"
  ; stats_yodac= "Metricas de YodaC"
  ; stats_api_version= "Version de API"
  ; stats_yoda_version= "Version de Yoda"
  ; stats_contributors= "Contribuidores"
  ; stats_requests_total= "Solicitudes totales"
  ; stats_requests_per_minute= "Solicitudes por minuto"
  ; stats_submissions_total= "Envios totales"
  ; stats_submissions_per_minute= "Envios por minuto"
  ; stats_queued_jobs_total= "Trabajos en cola"
  ; stats_queued_jobs_per_minute= "Trabajos en cola por minuto"
  ; stats_processed_jobs_total= "Trabajos procesados totales"
  ; stats_processed_jobs_per_minute= "Trabajos procesados por minuto"
  ; spinner_model_close= "Cerrar"
  ; problems_manage_title= "Gestión de problemas"
  ; problems_manage_subtitle=
      "Agrega, edita o elimina problemas y casos de prueba."
  ; problems_loading= "Cargando problemas..."
  ; problems_search_placeholder= "Buscar problemas..."
  ; problems_select_contest= "Seleccionar concurso"
  ; problems_no_contest= "Ningún concurso seleccionado"
  ; problems_add_btn= "Agregar problema"
  ; problems_add_title= "Agregar nuevo problema"
  ; problems_edit_title= "Editar problema"
  ; problems_code_label= "Código (slug: id-problem-name)"
  ; problems_title_label= "Título"
  ; problems_difficulty_label= "Dificultad"
  ; problems_time_limit_label= "Límite de tiempo (ms)"
  ; problems_memory_limit_label= "Límite de memoria (MB)"
  ; problems_description_label= "Descripción"
  ; problems_input_spec_label= "Especificación de entrada"
  ; problems_output_spec_label= "Especificación de salida"
  ; problems_cancel_btn= "Cancelar"
  ; problems_submit_btn= "Enviar"
  ; problems_save_changes= "Guardar cambios"
  ; problems_delete_confirm= "¿Eliminar este problema?"
  ; problems_testcases_title= "Casos de prueba"
  ; problems_add_testcase= "Agregar caso de prueba"
  ; problems_test_input_label= "Entrada"
  ; problems_test_output_label= "Salida"
  ; problems_is_sample_label= "Ejemplo"
  ; problems_edit_testcase= "Editar caso de prueba"
  ; problems_delete_testcase= "¿Eliminar caso de prueba?"
  ; problems_easy= "Fácil"
  ; problems_medium= "Medio"
  ; problems_hard= "Difícil"
  ; problems_error_load= "No se pudieron cargar los problemas: %s"
  ; problems_error_save= "No se pudo guardar el problema: %s"
  ; problems_error_delete= "No se pudo eliminar el problema."
  ; problems_success_created= "Problema creado."
  ; problems_success_updated= "Problema actualizado."
  ; problems_success_deleted= "Problema eliminado."
  ; problems_confirm_delete= "Confirmar eliminación" }

let pt =
  { login_placeholder_email= "nome@exemplo.com"
  ; login_placeholder_password= "Senha"
  ; login_sign_in= "Entrar"
  ; login_title= "Por favor, faça login"
  ; login_label_email= "Endereço de e-mail"
  ; login_label_password= "Senha"
  ; login_remember_me= "Lembrar-me"
  ; login_footer= "© A equipe Yoda 2026"
  ; sidebar_app_name= "YodaApp"
  ; tabbar_copy= "Copiar"
  ; tabbar_confirm_skeleton=
      "Deseja substituir o esqueleto? Todas as alterações não guardadas \
       serão perdidas."
  ; tabbar_skeleton= "Esqueleto"
  ; codebar_all_changes_saved= "Todas as alterações guardadas"
  ; codebar_saving= "Guardando..."
  ; spinner_modal_processing= "Processando..."
  ; spinner_modal_ready= "Pronto para começar."
  ; codebar_local_run= "Execução local"
  ; codebar_evaluate= "Avaliar"
  ; codebar_confirm_save=
      "Deseja avaliar e guardar permanentemente o seu trabalho '%s' ? Esta \
       ação não pode ser desfeita e contará para o seu limite de \
       submissões."
  ; codebar_evaluate_save= "Avaliar e guardar todo o seu trabalho"
  ; modal_confirm_action= "Confirmar ação"
  ; submission_sending= "Enviando sua solução..."
  ; submission_processing=
      "Processando sua solução... (verificando a cada 2s)"
  ; submission_result= "Resultado:"
  ; submission_close= "Fechar"
  ; codebar_run= "Executar o código"
  ; codebar_confirm_run= "Deseja executar o código '%s' ?"
  ; modal_cancel= "Cancelar"
  ; modal_confirm= "Confirmar"
  ; problem_submit_solution= "Envie sua solução abaixo."
  ; problem_time_limit= "Tempo limite"
  ; problem_memory_limit= "Limite de memória"
  ; problem_description= "Descrição"
  ; problem_input= "Entrada"
  ; problem_output= "Saída"
  ; problem_not_found= "Problema não encontrado"
  ; problem_submit_btn= "Enviar"
  ; subform_placeholder_source= "Código fonte"
  ; subform_label_language= "Linguagem:"
  ; subform_label_source= "Código fonte:"
  ; subform_submit= "Enviar"
  ; submissions_col_id= "#"
  ; submissions_col_problem= "Problema"
  ; submissions_col_language= "Linguagem"
  ; submissions_col_result= "Resultado"
  ; submissions_col_time= "Tempo"
  ; submissions_recent_title= "Envios recentes"
  ; contests_title= "Contests"
  ; problems_col_id= "ID"
  ; problems_col_name= "Problema"
  ; problems_title= "Problemas"
  ; settings_title= "Configurações"
  ; settings_theme_label= "Tema"
  ; settings_theme_desc= "Escolha o tema de cor do editor."
  ; settings_font_size_label= "Tamanho da fonte"
  ; settings_font_size_desc= "Ajuste o tamanho da fonte do editor."
  ; settings_tab_size_label= "Tamanho da tabulação"
  ; settings_tab_size_desc= "Número de espaços por indentação."
  ; settings_wrap_lines= "Quebrar linhas longas no editor."
  ; settings_auto_save= "Guardar automaticamente seu código enquanto digita."
  ; settings_save_btn= "Guardar"
  ; settings_reset_btn= "Redefinir"
  ; settings_language_label= "Idioma"
  ; config_editor_title= "Editor de configuração"
  ; config_history_title= "Histórico de configurações"
  ; config_col_version= "Versão"
  ; config_col_timestamp= "Carimbo de data/hora"
  ; config_col_changed_by= "Alterado por"
  ; config_col_action= "Ação"
  ; config_col_langs= "Idiomas"
  ; config_loading_history= "Carregando histórico..."
  ; settings_appearance_title= "Aparência"
  ; settings_editor_title= "Editor"
  ; settings_behavior_title= "Comportamento"
  ; settings_tab_general= "Geral"
  ; settings_tab_yodac= "YodaC"
  ; settings_tab_users= "Utilizadores"
  ; settings_tab_problems= "Problemas"
  ; settings_line_wrap_label= "Quebrar linhas"
  ; settings_auto_save_label= "Guarda de forma automática"
  ; settings_admin_badge= "Acesso de Administrador"
  ; settings_judge_badge= "Acesso de Juiz"
  ; config_meta_version= "Versão: %s"
  ; config_meta_updated= "Atualizado: %s"
  ; config_meta_by= "Por: %s"
  ; config_total_entries= "Total de entradas: %s"
  ; config_no_history= "Sem histórico"
  ; config_save_no_changes= "Não há alterações para guardar."
  ; config_edit_btn= "Editar"
  ; config_cancel_edit_btn= "Cancelar"
  ; progress_status_label= "Status: "
  ; progress_time_left_label= "Tempo restante: "
  ; progress_progress_label= "Progresso"
  ; progress_title= "Progresso do concurso"
  ; test_type_text= "Texto"
  ; test_type_json= "JSON"
  ; test_invalid_json= "JSON inválido"
  ; dropdown_select_problem= "-- Selecione um problema --"
  ; sidebar_dashboard= "Painel"
  ; sidebar_codeboard= "Codeboard"
  ; sidebar_submissions= "Envios"
  ; sidebar_switch_contest= "Trocar concurso"
  ; sidebar_settings= "Configurações"
  ; sidebar_sign_out= "Sair"
  ; login_sign_out= "Sair"
  ; users_manage_title= "Gestão de utilizadores"
  ; users_manage_subtitle=
      "Crie contas e atualize funções diretamente nesta tabela."
  ; users_loading= "Carregando utilizadores..."
  ; users_refresh_btn= "Atualizar"
  ; users_create_title= "Adicionar utilizador"
  ; users_create_username_placeholder= "Nome de utilizador"
  ; users_create_password= "Senha"
  ; users_create_password_placeholder= "Senha temporária"
  ; users_groups_placeholder= "grupo-a, grupo-b"
  ; users_create_submit= "Criar utilizador"
  ; users_col_id= "ID"
  ; users_col_username= "Nome de utilizador"
  ; users_col_role= "Função"
  ; users_col_groups= "Grupos"
  ; users_col_created_at= "Criado"
  ; users_col_last_seen_at= "Última atividade"
  ; users_col_actions= "Ações"
  ; users_select_all= "Selecionar tudo"
  ; users_delete_selected_btn= "Eliminar selecionados (%s)"
  ; users_delete_confirm= "Eliminar %s utilizadores selecionados?"
  ; users_delete_failed= "Falha ao eliminar %s utilizadores selecionados."
  ; users_notice_deleted= "Utilizadores selecionados eliminados com sucesso."
  ; users_action_edit= "Editar"
  ; users_action_save= "Guardar"
  ; users_action_cancel= "Cancelar"
  ; users_notice_created= "Utilizador criado com sucesso."
  ; users_notice_updated= "Utilizador atualizado com sucesso."
  ; users_validation_required=
      "Nome de utilizador e senha são obrigatórios para criar um utilizador."
  ; users_import_in_progress= "Importando utilizadores..."
  ; users_import_summary=
      "Importação concluída: %s utilizadores criados, %s erros."
  ; users_import_invalid_header=
      "Cabeçalho CSV inválido. Esperado: username,password,role,groups"
  ; users_import_invalid_row= "Linha CSV inválida na linha"
  ; users_import_invalid_role= "Função inválida na linha"
  ; users_import_read_failed= "Falha ao ler o ficheiro CSV selecionado."
  ; users_import_input_missing=
      "O campo de ficheiro de importação não está disponível nesta página."
  ; users_import_empty_file= "O ficheiro CSV selecionado está vazio."
  ; users_import_btn= "Importar utilizadores"
  ; settings_tab_stats= "Estatisticas"
  ; stats_loading= "Carregando estatisticas..."
  ; stats_empty= "Sem estatisticas disponiveis."
  ; stats_refresh_btn= "Atualizar"
  ; stats_error_prefix= "Falha ao carregar estatisticas (HTTP %s)"
  ; stats_parse_error= "Falha ao analisar estatisticas: %s"
  ; stats_service_info= "Informacoes do servico"
  ; stats_yodab= "Metricas do YodaB"
  ; stats_yodac= "Metricas do YodaC"
  ; stats_api_version= "Versao da API"
  ; stats_yoda_version= "Versao do Yoda"
  ; stats_contributors= "Contribuidores"
  ; stats_requests_total= "Total de requisicoes"
  ; stats_requests_per_minute= "Requisicoes por minuto"
  ; stats_submissions_total= "Total de envios"
  ; stats_submissions_per_minute= "Envios por minuto"
  ; stats_queued_jobs_total= "Tarefas na fila"
  ; stats_queued_jobs_per_minute= "Tarefas na fila por minuto"
  ; stats_processed_jobs_total= "Total de tarefas processadas"
  ; stats_processed_jobs_per_minute= "Tarefas processadas por minuto"
  ; spinner_model_close= "Fechar"
  ; problems_manage_title= "Gestão de problemas"
  ; problems_manage_subtitle=
      "Adicione, edite ou remova problemas e casos de teste."
  ; problems_loading= "Carregando problemas..."
  ; problems_search_placeholder= "Procurar problemas..."
  ; problems_select_contest= "Selecionar concurso"
  ; problems_no_contest= "Nenhum concurso selecionado"
  ; problems_add_btn= "Adicionar problema"
  ; problems_add_title= "Adicionar novo problema"
  ; problems_edit_title= "Editar problema"
  ; problems_code_label= "Código (slug: id-problem-name)"
  ; problems_title_label= "Título"
  ; problems_difficulty_label= "Dificuldade"
  ; problems_time_limit_label= "Limite de tempo (ms)"
  ; problems_memory_limit_label= "Limite de memória (MB)"
  ; problems_description_label= "Descrição"
  ; problems_input_spec_label= "Especificação de entrada"
  ; problems_output_spec_label= "Especificação de saída"
  ; problems_cancel_btn= "Cancelar"
  ; problems_submit_btn= "Enviar"
  ; problems_save_changes= "Guardar alterações"
  ; problems_delete_confirm= "Eliminar este problema?"
  ; problems_testcases_title= "Casos de teste"
  ; problems_add_testcase= "Adicionar caso de teste"
  ; problems_test_input_label= "Entrada"
  ; problems_test_output_label= "Saída"
  ; problems_is_sample_label= "Exemplo"
  ; problems_edit_testcase= "Editar caso de teste"
  ; problems_delete_testcase= "Eliminar caso de teste?"
  ; problems_easy= "Fácil"
  ; problems_medium= "Médio"
  ; problems_hard= "Difícil"
  ; problems_error_load= "Falha ao carregar problemas: %s"
  ; problems_error_save= "Falha ao guardar problema: %s"
  ; problems_error_delete= "Falha ao eliminar problema."
  ; problems_success_created= "Problema criado."
  ; problems_success_updated= "Problema atualizado."
  ; problems_success_deleted= "Problema eliminado."
  ; problems_confirm_delete= "Confirmar eliminação" }

let ar =
  { login_placeholder_email= "name@example.com"
  ; login_placeholder_password= "كلمة المرور"
  ; login_sign_in= "تسجيل الدخول"
  ; login_title= "يرجى تسجيل الدخول"
  ; login_label_email= "عنوان البريد الإلكتروني"
  ; login_label_password= "كلمة المرور"
  ; login_remember_me= "تذكرني"
  ; login_footer= "© فريق يودا 2026"
  ; sidebar_app_name= "YodaApp"
  ; tabbar_copy= "نسخ"
  ; tabbar_confirm_skeleton= "هل تريد استبدال الهيكل العظمي؟"
  ; tabbar_skeleton= "الهيكل"
  ; codebar_all_changes_saved= "تم حفظ جميع التغييرات"
  ; codebar_saving= "جارٍ الحفظ..."
  ; spinner_modal_processing= "جارٍ المعالجة..."
  ; spinner_modal_ready= "جاهز للبدء."
  ; codebar_local_run= "تشغيل محلي"
  ; codebar_evaluate= "تقييم"
  ; codebar_confirm_save=
      "هل تريد تقييم وحفظ عملك بشكل دائم لـ '%s' ؟ لا يمكن التراجع عن هذا \
       الإجراء وسيتم احتسابه ضمن حد الإرسال الخاص بك."
  ; codebar_evaluate_save= "تقييم وحفظ كل عملك"
  ; modal_confirm_action= "تأكيد الإجراء"
  ; submission_sending= "جارٍ إرسال حلّك..."
  ; submission_processing= "جارٍ معالجة حلّك... (الاستعلام كل ثانيتين)"
  ; submission_result= "النتيجة:"
  ; submission_close= "إغلاق"
  ; codebar_run= "تشغيل الكود"
  ; codebar_confirm_run= "هل تريد تشغيل الكود '%s'?"
  ; modal_cancel= "إلغاء"
  ; modal_confirm= "تأكيد"
  ; problem_submit_solution= "قدم حلك أدناه."
  ; problem_time_limit= "الوقت المحدد"
  ; problem_memory_limit= "حد الذاكرة"
  ; problem_description= "الوصف"
  ; problem_input= "الإدخال"
  ; problem_output= "المخرج"
  ; problem_not_found= "المشكلة غير موجودة"
  ; problem_submit_btn= "إرسال"
  ; subform_placeholder_source= "الكود المصدري"
  ; subform_label_language= "اللغة:"
  ; subform_label_source= "الكود المصدري:"
  ; subform_submit= "إرسال"
  ; submissions_col_id= "#"
  ; submissions_col_problem= "المشكلة"
  ; submissions_col_language= "اللغة"
  ; submissions_col_result= "النتيجة"
  ; submissions_col_time= "الوقت"
  ; submissions_recent_title= "الإرسالات الأخيرة"
  ; contests_title= "المسابقات"
  ; problems_col_id= "المعرّف"
  ; problems_col_name= "المشكلة"
  ; problems_title= "المشاكل"
  ; settings_title= "الإعدادات"
  ; settings_theme_label= "السمة"
  ; settings_theme_desc= "اختر سمة لون المحرر."
  ; settings_font_size_label= "حجم الخط"
  ; settings_font_size_desc= "اضبط حجم خط المحرر."
  ; settings_tab_size_label= "حجم المسافة البادئة"
  ; settings_tab_size_desc= "عدد المسافات لكل مسافة بادئة."
  ; settings_wrap_lines= "تغليف الأسطر الطويلة في المحرر."
  ; settings_auto_save= "حفظ الكود تلقائياً أثناء الكتابة."
  ; settings_save_btn= "حفظ"
  ; settings_reset_btn= "إعادة تعيين"
  ; settings_language_label= "اللغة"
  ; config_editor_title= "محرر التكوين"
  ; config_history_title= "سجل التكوين"
  ; config_col_version= "الإصدار"
  ; config_col_timestamp= "الطابع الزمني"
  ; config_col_changed_by= "تم التغيير بواسطة"
  ; config_col_action= "الإجراء"
  ; config_col_langs= "اللغات"
  ; config_loading_history= "جاري تحميل السجل..."
  ; settings_appearance_title= "المظهر"
  ; settings_editor_title= "المحرر"
  ; settings_behavior_title= "السلوك"
  ; settings_tab_general= "عام"
  ; settings_tab_yodac= "يوداك"
  ; settings_tab_users= "المستخدمون"
  ; settings_tab_problems= "المشاكل"
  ; settings_line_wrap_label= "تغليف الأسطر"
  ; settings_auto_save_label= "حفظ تلقائي"
  ; settings_admin_badge= "وصول المسؤول"
  ; settings_judge_badge= "وصول القاضي"
  ; config_meta_version= "الإصدار: %s"
  ; config_meta_updated= "المحدّث: %s"
  ; config_meta_by= "بواسطة: %s"
  ; config_total_entries= "إجمالي الإدخالات: %s"
  ; config_no_history= "لا يوجد سجل"
  ; config_save_no_changes= "لا توجد تغييرات للحفظ."
  ; config_edit_btn= "تحرير"
  ; config_cancel_edit_btn= "إلغاء"
  ; progress_status_label= "الحالة: "
  ; progress_time_left_label= "الوقت المتبقي: "
  ; progress_progress_label= "التقدم"
  ; progress_title= "تقدم المسابقة"
  ; test_type_text= "نص"
  ; test_type_json= "JSON"
  ; test_invalid_json= "JSON غير صالح"
  ; dropdown_select_problem= "-- اختر مشكلة --"
  ; sidebar_dashboard= "لوحة القيادة"
  ; sidebar_codeboard= "لوحة الكود"
  ; sidebar_submissions= "الإرسالات"
  ; sidebar_switch_contest= "تبديل المسابقة"
  ; sidebar_settings= "الإعدادات"
  ; sidebar_sign_out= "تسجيل الخروج"
  ; login_sign_out= "تسجيل الخروج"
  ; users_manage_title= "إدارة المستخدمين"
  ; users_manage_subtitle= "أنشئ الحسابات وعدل الأدوار مباشرة من هذا الجدول."
  ; users_loading= "جارٍ تحميل المستخدمين..."
  ; users_refresh_btn= "تحديث"
  ; users_create_title= "إضافة مستخدم جديد"
  ; users_create_username_placeholder= "اسم المستخدم"
  ; users_create_password= "كلمة المرور"
  ; users_create_password_placeholder= "كلمة مرور مؤقتة"
  ; users_groups_placeholder= "المجموعة-a، المجموعة-b"
  ; users_create_submit= "إنشاء مستخدم"
  ; users_col_id= "المعرّف"
  ; users_col_username= "اسم المستخدم"
  ; users_col_role= "الدور"
  ; users_col_groups= "المجموعات"
  ; users_col_created_at= "تاريخ الإنشاء"
  ; users_col_last_seen_at= "آخر ظهور"
  ; users_col_actions= "الإجراءات"
  ; users_select_all= "تحديد الكل"
  ; users_delete_selected_btn= "حذف المحدد (%s)"
  ; users_delete_confirm= "حذف %s من المستخدمين المحددين؟"
  ; users_delete_failed= "فشل حذف %s من المستخدمين المحددين."
  ; users_notice_deleted= "تم حذف المستخدمين المحددين بنجاح."
  ; users_action_edit= "تحرير"
  ; users_action_save= "حفظ"
  ; users_action_cancel= "إلغاء"
  ; users_notice_created= "تم إنشاء المستخدم بنجاح."
  ; users_notice_updated= "تم تحديث المستخدم بنجاح."
  ; users_validation_required=
      "اسم المستخدم وكلمة المرور مطلوبان لإنشاء مستخدم جديد."
  ; users_import_in_progress= "جارٍ استيراد المستخدمين..."
  ; users_import_summary= "اكتمل الاستيراد: تم إنشاء %s مستخدمين، و%s أخطاء."
  ; users_import_invalid_header=
      "رأس CSV غير صالح. المتوقع: username,password,role,groups"
  ; users_import_invalid_row= "صف CSV غير صالح في السطر"
  ; users_import_invalid_role= "دور غير صالح في السطر"
  ; users_import_read_failed= "فشل في قراءة ملف CSV المحدد."
  ; users_import_input_missing= "حقل ملف الاستيراد غير متوفر في هذه الصفحة."
  ; users_import_empty_file= "ملف CSV المحدد فارغ."
  ; users_import_btn= "استيراد المستخدمين"
  ; settings_tab_stats= "الإحصاءات"
  ; stats_loading= "جارٍ تحميل الإحصاءات..."
  ; stats_empty= "لا توجد إحصاءات متاحة."
  ; stats_refresh_btn= "تحديث"
  ; stats_error_prefix= "تعذر تحميل الإحصاءات (HTTP %s)"
  ; stats_parse_error= "تعذر تحليل الإحصاءات: %s"
  ; stats_service_info= "معلومات الخدمة"
  ; stats_yodab= "مقاييس YodaB"
  ; stats_yodac= "مقاييس YodaC"
  ; stats_api_version= "إصدار API"
  ; stats_yoda_version= "إصدار Yoda"
  ; stats_contributors= "المساهمون"
  ; stats_requests_total= "إجمالي الطلبات"
  ; stats_requests_per_minute= "الطلبات في الدقيقة"
  ; stats_submissions_total= "إجمالي الإرسالات"
  ; stats_submissions_per_minute= "الإرسالات في الدقيقة"
  ; stats_queued_jobs_total= "المهام في الطابور"
  ; stats_queued_jobs_per_minute= "المهام في الطابور لكل دقيقة"
  ; stats_processed_jobs_total= "إجمالي المهام المعالجة"
  ; stats_processed_jobs_per_minute= "المهام المعالجة لكل دقيقة"
  ; spinner_model_close= "ابدأ"
  ; problems_manage_title= "إدارة المشاكل"
  ; problems_manage_subtitle= "أضف أو حرر أو احذف المشاكل وحالات الاختبار."
  ; problems_loading= "جارٍ تحميل المشاكل..."
  ; problems_search_placeholder= "البحث عن المشاكل..."
  ; problems_select_contest= "تحديد المسابقة"
  ; problems_no_contest= "لم يتم تحديد أي مسابقة"
  ; problems_add_btn= "إضافة مشكلة"
  ; problems_add_title= "إضافة مشكلة جديدة"
  ; problems_edit_title= "تحرير المشكلة"
  ; problems_code_label= "الرمز (slug: id-problem-name)"
  ; problems_title_label= "العنوان"
  ; problems_difficulty_label= "الصعوبة"
  ; problems_time_limit_label= "الحد الزمني (مللي ثانية)"
  ; problems_memory_limit_label= "حد الذاكرة (ميغابايت)"
  ; problems_description_label= "الوصف"
  ; problems_input_spec_label= "مواصفات الإدخال"
  ; problems_output_spec_label= "مواصفات الإخراج"
  ; problems_cancel_btn= "إلغاء"
  ; problems_submit_btn= "إرسال"
  ; problems_save_changes= "حفظ التغييرات"
  ; problems_delete_confirm= "هل تريد حذف هذه المشكلة؟"
  ; problems_testcases_title= "حالات الاختبار"
  ; problems_add_testcase= "إضافة حالة اختبار"
  ; problems_test_input_label= "الإدخال"
  ; problems_test_output_label= "الإخراج"
  ; problems_is_sample_label= "عينة"
  ; problems_edit_testcase= "تحرير حالة الاختبار"
  ; problems_delete_testcase= "هل تريد حذف حالة الاختبار؟"
  ; problems_easy= "سهل"
  ; problems_medium= "متوسط"
  ; problems_hard= "صعب"
  ; problems_error_load= "تعذر تحميل المشاكل: %s"
  ; problems_error_save= "تعذر حفظ المشكلة: %s"
  ; problems_error_delete= "تعذر حذف المشكلة."
  ; problems_success_created= "تم إنشاء المشكلة."
  ; problems_success_updated= "تم تحديث المشكلة."
  ; problems_success_deleted= "تم حذف المشكلة."
  ; problems_confirm_delete= "تأكيد الحذف" }

let map : translations -> (string, string) Hashtbl.t =
 fun tr ->
  let h = Hashtbl.create 55 in
  let add k v = Hashtbl.add h k v in
  add "login_placeholder_email" tr.login_placeholder_email ;
  add "login_placeholder_password" tr.login_placeholder_password ;
  add "login_sign_in" tr.login_sign_in ;
  add "login_title" tr.login_title ;
  add "login_label_email" tr.login_label_email ;
  add "login_label_password" tr.login_label_password ;
  add "login_remember_me" tr.login_remember_me ;
  add "login_footer" tr.login_footer ;
  add "sidebar_app_name" tr.sidebar_app_name ;
  add "tabbar_copy" tr.tabbar_copy ;
  add "tabbar_confirm_skeleton" tr.tabbar_confirm_skeleton ;
  add "tabbar_skeleton" tr.tabbar_skeleton ;
  add "codebar_all_changes_saved" tr.codebar_all_changes_saved ;
  add "codebar_saving" tr.codebar_saving ;
  add "spinner_modal_processing" tr.spinner_modal_processing ;
  add "spinner_modal_ready" tr.spinner_modal_ready ;
  add "codebar_local_run" tr.codebar_local_run ;
  add "codebar_evaluate" tr.codebar_evaluate ;
  add "codebar_confirm_save" tr.codebar_confirm_save ;
  add "codebar_evaluate_save" tr.codebar_evaluate_save ;
  add "codebar_run" tr.codebar_run ;
  add "codebar_confirm_run" tr.codebar_confirm_run ;
  add "modal_cancel" tr.modal_cancel ;
  add "modal_confirm" tr.modal_confirm ;
  add "modal_confirm_action" tr.modal_confirm_action ;
  add "submission_sending" tr.submission_sending ;
  add "submission_processing" tr.submission_processing ;
  add "submission_result" tr.submission_result ;
  add "submission_close" tr.submission_close ;
  add "problem_submit_solution" tr.problem_submit_solution ;
  add "problem_time_limit" tr.problem_time_limit ;
  add "problem_memory_limit" tr.problem_memory_limit ;
  add "problem_description" tr.problem_description ;
  add "problem_input" tr.problem_input ;
  add "problem_output" tr.problem_output ;
  add "problem_not_found" tr.problem_not_found ;
  add "problem_submit_btn" tr.problem_submit_btn ;
  add "subform_placeholder_source" tr.subform_placeholder_source ;
  add "subform_label_language" tr.subform_label_language ;
  add "subform_label_source" tr.subform_label_source ;
  add "subform_submit" tr.subform_submit ;
  add "submissions_col_id" tr.submissions_col_id ;
  add "submissions_col_problem" tr.submissions_col_problem ;
  add "submissions_col_language" tr.submissions_col_language ;
  add "submissions_col_result" tr.submissions_col_result ;
  add "submissions_col_time" tr.submissions_col_time ;
  add "submissions_recent_title" tr.submissions_recent_title ;
  add "contests_title" tr.contests_title ;
  add "problems_col_id" tr.problems_col_id ;
  add "problems_col_name" tr.problems_col_name ;
  add "problems_title" tr.problems_title ;
  add "settings_title" tr.settings_title ;
  add "settings_theme_label" tr.settings_theme_label ;
  add "settings_theme_desc" tr.settings_theme_desc ;
  add "settings_font_size_label" tr.settings_font_size_label ;
  add "settings_font_size_desc" tr.settings_font_size_desc ;
  add "settings_tab_size_label" tr.settings_tab_size_label ;
  add "settings_tab_size_desc" tr.settings_tab_size_desc ;
  add "settings_wrap_lines" tr.settings_wrap_lines ;
  add "settings_auto_save" tr.settings_auto_save ;
  add "settings_save_btn" tr.settings_save_btn ;
  add "settings_reset_btn" tr.settings_reset_btn ;
  add "settings_language_label" tr.settings_language_label ;
  add "config_editor_title" tr.config_editor_title ;
  add "config_history_title" tr.config_history_title ;
  add "config_col_version" tr.config_col_version ;
  add "config_col_timestamp" tr.config_col_timestamp ;
  add "config_col_changed_by" tr.config_col_changed_by ;
  add "config_col_action" tr.config_col_action ;
  add "config_col_langs" tr.config_col_langs ;
  add "config_loading_history" tr.config_loading_history ;
  add "settings_appearance_title" tr.settings_appearance_title ;
  add "settings_editor_title" tr.settings_editor_title ;
  add "settings_behavior_title" tr.settings_behavior_title ;
  add "settings_tab_general" tr.settings_tab_general ;
  add "settings_tab_yodac" tr.settings_tab_yodac ;
  add "settings_tab_users" tr.settings_tab_users ;
  add "settings_tab_problems" tr.settings_tab_problems ;
  add "settings_line_wrap_label" tr.settings_line_wrap_label ;
  add "settings_auto_save_label" tr.settings_auto_save_label ;
  add "settings_admin_badge" tr.settings_admin_badge ;
  add "settings_judge_badge" tr.settings_judge_badge ;
  add "config_meta_version" tr.config_meta_version ;
  add "config_meta_updated" tr.config_meta_updated ;
  add "config_meta_by" tr.config_meta_by ;
  add "config_total_entries" tr.config_total_entries ;
  add "config_no_history" tr.config_no_history ;
  add "config_save_no_changes" tr.config_save_no_changes ;
  add "config_edit_btn" tr.config_edit_btn ;
  add "config_cancel_edit_btn" tr.config_cancel_edit_btn ;
  add "progress_status_label" tr.progress_status_label ;
  add "progress_time_left_label" tr.progress_time_left_label ;
  add "progress_progress_label" tr.progress_progress_label ;
  add "progress_title" tr.progress_title ;
  add "test_type_text" tr.test_type_text ;
  add "test_type_json" tr.test_type_json ;
  add "test_invalid_json" tr.test_invalid_json ;
  add "dropdown_select_problem" tr.dropdown_select_problem ;
  add "sidebar_dashboard" tr.sidebar_dashboard ;
  add "sidebar_codeboard" tr.sidebar_codeboard ;
  add "sidebar_submissions" tr.sidebar_submissions ;
  add "sidebar_switch_contest" tr.sidebar_switch_contest ;
  add "sidebar_settings" tr.sidebar_settings ;
  add "sidebar_sign_out" tr.sidebar_sign_out ;
  add "login_sign_out" tr.login_sign_out ;
  add "users_manage_title" tr.users_manage_title ;
  add "users_manage_subtitle" tr.users_manage_subtitle ;
  add "users_loading" tr.users_loading ;
  add "users_refresh_btn" tr.users_refresh_btn ;
  add "users_create_title" tr.users_create_title ;
  add "users_create_username_placeholder"
    tr.users_create_username_placeholder ;
  add "users_create_password" tr.users_create_password ;
  add "users_create_password_placeholder"
    tr.users_create_password_placeholder ;
  add "users_groups_placeholder" tr.users_groups_placeholder ;
  add "users_create_submit" tr.users_create_submit ;
  add "users_col_id" tr.users_col_id ;
  add "users_col_username" tr.users_col_username ;
  add "users_col_role" tr.users_col_role ;
  add "users_col_groups" tr.users_col_groups ;
  add "users_col_created_at" tr.users_col_created_at ;
  add "users_col_last_seen_at" tr.users_col_last_seen_at ;
  add "users_col_actions" tr.users_col_actions ;
  add "users_select_all" tr.users_select_all ;
  add "users_delete_selected_btn" tr.users_delete_selected_btn ;
  add "users_delete_confirm" tr.users_delete_confirm ;
  add "users_delete_failed" tr.users_delete_failed ;
  add "users_notice_deleted" tr.users_notice_deleted ;
  add "users_action_edit" tr.users_action_edit ;
  add "users_action_save" tr.users_action_save ;
  add "users_action_cancel" tr.users_action_cancel ;
  add "users_notice_created" tr.users_notice_created ;
  add "users_notice_updated" tr.users_notice_updated ;
  add "users_validation_required" tr.users_validation_required ;
  add "users_import_in_progress" tr.users_import_in_progress ;
  add "users_import_summary" tr.users_import_summary ;
  add "users_import_invalid_header" tr.users_import_invalid_header ;
  add "users_import_invalid_row" tr.users_import_invalid_row ;
  add "users_import_invalid_role" tr.users_import_invalid_role ;
  add "users_import_read_failed" tr.users_import_read_failed ;
  add "users_import_input_missing" tr.users_import_input_missing ;
  add "users_import_empty_file" tr.users_import_empty_file ;
  add "users_import_btn" tr.users_import_btn ;
  add "settings_tab_stats" tr.settings_tab_stats ;
  add "stats_loading" tr.stats_loading ;
  add "stats_empty" tr.stats_empty ;
  add "stats_refresh_btn" tr.stats_refresh_btn ;
  add "stats_error_prefix" tr.stats_error_prefix ;
  add "stats_parse_error" tr.stats_parse_error ;
  add "stats_service_info" tr.stats_service_info ;
  add "stats_yodab" tr.stats_yodab ;
  add "stats_yodac" tr.stats_yodac ;
  add "stats_api_version" tr.stats_api_version ;
  add "stats_yoda_version" tr.stats_yoda_version ;
  add "stats_contributors" tr.stats_contributors ;
  add "stats_requests_total" tr.stats_requests_total ;
  add "stats_requests_per_minute" tr.stats_requests_per_minute ;
  add "stats_submissions_total" tr.stats_submissions_total ;
  add "stats_submissions_per_minute" tr.stats_submissions_per_minute ;
  add "stats_queued_jobs_total" tr.stats_queued_jobs_total ;
  add "stats_queued_jobs_per_minute" tr.stats_queued_jobs_per_minute ;
  add "stats_processed_jobs_total" tr.stats_processed_jobs_total ;
  add "stats_processed_jobs_per_minute" tr.stats_processed_jobs_per_minute ;
  add "spinner_model_close" tr.spinner_model_close ;
  add "problems_manage_title" tr.problems_manage_title ;
  add "problems_manage_subtitle" tr.problems_manage_subtitle ;
  add "problems_loading" tr.problems_loading ;
  add "problems_search_placeholder" tr.problems_search_placeholder ;
  add "problems_select_contest" tr.problems_select_contest ;
  add "problems_no_contest" tr.problems_no_contest ;
  add "problems_add_btn" tr.problems_add_btn ;
  add "problems_add_title" tr.problems_add_title ;
  add "problems_edit_title" tr.problems_edit_title ;
  add "problems_code_label" tr.problems_code_label ;
  add "problems_title_label" tr.problems_title_label ;
  add "problems_difficulty_label" tr.problems_difficulty_label ;
  add "problems_time_limit_label" tr.problems_time_limit_label ;
  add "problems_memory_limit_label" tr.problems_memory_limit_label ;
  add "problems_description_label" tr.problems_description_label ;
  add "problems_input_spec_label" tr.problems_input_spec_label ;
  add "problems_output_spec_label" tr.problems_output_spec_label ;
  add "problems_cancel_btn" tr.problems_cancel_btn ;
  add "problems_submit_btn" tr.problems_submit_btn ;
  add "problems_save_changes" tr.problems_save_changes ;
  add "problems_delete_confirm" tr.problems_delete_confirm ;
  add "problems_testcases_title" tr.problems_testcases_title ;
  add "problems_add_testcase" tr.problems_add_testcase ;
  add "problems_test_input_label" tr.problems_test_input_label ;
  add "problems_test_output_label" tr.problems_test_output_label ;
  add "problems_is_sample_label" tr.problems_is_sample_label ;
  add "problems_edit_testcase" tr.problems_edit_testcase ;
  add "problems_delete_testcase" tr.problems_delete_testcase ;
  add "problems_easy" tr.problems_easy ;
  add "problems_medium" tr.problems_medium ;
  add "problems_hard" tr.problems_hard ;
  h
