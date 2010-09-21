class SearchController < ApplicationController
  before_filter :login_required
  access_control do
    allow :admin
    allow :manager
    allow :team
  end
  def index
    if params[:q].to_s != ""
      if params[:criteria] == "Job Information"
        @jobs = Job.name_like_any_or_number_like_any_or_description_like_any_or_state_like_any(params[:q].to_s.split).client_user_id_eq(as_user).is_archive_eq(false)
      elsif params[:criteria] == "Division"
        @divisions = Specification.division_name_like_any(params[:q].to_s.split).job_client_user_id_eq(as_user).job_is_archive_eq(false)
      elsif  params[:criteria] == "Section"
        @specification_sections = SpecificationSection.section_name_like_any(params[:q].to_s.split).specification_job_client_user_id_eq(as_user).specification_job_is_archive_eq(false)
      elsif  params[:criteria] == "Article"
        @articles  = PartArticle.article_name_like_any(params[:q].to_s.split).specification_section_specification_job_client_user_id_eq(as_user).specification_section_specification_job_is_archive_eq(false)
      elsif  params[:criteria] == "Paragraph"
        @paragraphs  = ArticleParagraph.paragraph_name_like_any(params[:q].to_s.split).part_article_specification_section_specification_job_client_user_id_eq(as_user).part_article_specification_section_specification_job_is_archive_eq(false)
      elsif  params[:criteria] == "Subparagraph"
        @subparagraphs  = Subparagraph.description_like_any(params[:q].to_s.split).article_paragraph_part_article_specification_section_specification_job_client_user_id_eq(as_user).article_paragraph_part_article_specification_section_specification_job_is_archive_eq(false)
      elsif  params[:criteria] == "Notes"
        @notes  = SectionNote.note_like_any_or_title_like_any(params[:q].to_s.split).user_id_eq(as_user).specification_section_specification_job_is_archive_eq(false)
      elsif  params[:criteria] == "Attachments"
        @attachments  = SectionAttachment.note_like_any_or_title_like_any_or_asset_file_name_like_any(params[:q].to_s.split).user_id_eq(as_user).specification_section_specification_job_is_archive_eq(false)
      elsif  params[:criteria] == "Documents"
        @documents  = SectionDocument.note_like_any_or_title_like_any_or_doc_file_name_like_any(params[:q].to_s.split).user_id_eq(as_user).specification_section_specification_job_is_archive_eq(false)
      elsif  params[:criteria] == "CSI MasterFormat"
        @sections  = Section.name_like_any(params[:q].to_s.split)
      end

    end
  end
end 
